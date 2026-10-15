require "test_helper"

class ImageAttachmentValidatorTest < ActiveSupport::TestCase
  def build_project(content_type:, size:)
    project = Project.new(name: "Projet de test")

    project.project_photo.attach(
      io: StringIO.new("x" * size),
      filename: "image_test",
      content_type: content_type
    )

    project
  end

  test "accepte une image JPEG" do
    project = build_project(content_type: "image/jpeg", size: 1024)
    assert project.valid?, project.errors.full_messages.join(", ")
  end

  test "accepte une image PNG" do
    project = build_project(content_type: "image/png", size: 1024)
    assert project.valid?, project.errors.full_messages.join(", ")
  end

  test "accepte une image WebP" do
    project = build_project(content_type: "image/webp", size: 1024)
    assert project.valid?, project.errors.full_messages.join(", ")
  end

  test "refuse une image SVG" do
    project = build_project(content_type: "image/svg+xml", size: 1024)
    assert_not project.valid?
    assert project.errors[:project_photo].any?
  end

  test "refuse un fichier trop volumineux" do
    project = build_project(content_type: "image/jpeg", size: 6.megabytes)
    assert_not project.valid?
    assert project.errors[:project_photo].any?
  end

  test "autorise la modification d'un outil avec un SVG existant" do
    tool = Tool.create!(name: "Ruby")

    # Simule un fichier SVG enregistré avant l'ajout du validateur.
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("<svg></svg>"),
      filename: "ruby.svg",
      content_type: "image/svg+xml"
    )

    ActiveStorage::Attachment.create!(
      name: "tool_photo",
      record: tool,
      blob: blob
    )

    tool.reload
    tool.name = "Ruby Language"

    assert tool.valid?, tool.errors.full_messages.join(", ")
  end

  test "refuse un SVG parmi plusieurs photos" do
    project = Project.new(name: "Galerie de test")

    project.photos.attach(
      io: StringIO.new("image png"),
      filename: "photo.png",
      content_type: "image/png"
    )

    project.photos.attach(
      io: StringIO.new("<svg></svg>"),
      filename: "photo.svg",
      content_type: "image/svg+xml"
    )

    assert_not project.valid?
    assert project.errors[:photos].any?
  end

  test "autorise l'ajout d'une photo valide à une galerie existante" do
    project = Project.create!(name: "Galerie existante")

    project.photos.attach(
      io: StringIO.new("premiere image"),
      filename: "photo1.png",
      content_type: "image/png"
    )

    project.reload

    project.photos.attach(
      io: StringIO.new("deuxieme image"),
      filename: "photo2.jpg",
      content_type: "image/jpeg"
    )

    assert project.valid?, project.errors.full_messages.join(", ")
    assert_equal 2, project.photos.blobs.size
  end

  test "autorise le remplacement d'une image existante" do
    tool = Tool.create!(name: "Ruby")

    tool.tool_photo.attach(
      io: StringIO.new("ancienne image"),
      filename: "ancienne.png",
      content_type: "image/png"
    )

    tool.reload

    tool.tool_photo.attach(
      io: StringIO.new("nouvelle image"),
      filename: "nouvelle.webp",
      content_type: "image/webp"
    )

    assert tool.valid?, tool.errors.full_messages.join(", ")
    assert_equal "nouvelle.webp", tool.tool_photo.filename.to_s
  end
end