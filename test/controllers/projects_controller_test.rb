require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(
      email: "admin-gallery-test@example.com",
      password: "Password123!",
      admin: true
    )

    sign_in @admin

    @project = Project.create!(name: "Projet galerie test")
  end

  test "adding a photo preserves existing photos" do
    @project.photos.attach(
      io: StringIO.new("first image"),
      filename: "first.jpg",
      content_type: "image/jpeg"
    )

    assert_equal 1, @project.photos.count

    patch project_path(@project), params: {
      project: {
        name: @project.name,
        photos: [
          fixture_file_upload(
            "test_image.jpg",
            "image/jpeg"
          )
        ]
      }
    }

    assert_redirected_to project_path(@project)
    assert_equal 2, @project.reload.photos.count
  end

  test "removing one photo preserves the others" do
    2.times do |index|
      @project.photos.attach(
        io: StringIO.new("image #{index}"),
        filename: "photo_#{index}.jpg",
        content_type: "image/jpeg"
      )
    end

    assert_equal 2, @project.photos.count

    photo_to_remove = @project.photos.attachments.first
    photo_to_keep = @project.photos.attachments.last
    kept_blob_id = photo_to_keep.blob_id

    patch project_path(@project), params: {
      project: {
        name: @project.name,
        remove_photo_ids: [photo_to_remove.id.to_s]
      }
    }

    assert_redirected_to project_path(@project)

    @project.reload

    assert_equal 1, @project.photos.count
    assert_equal kept_blob_id, @project.photos.first.blob_id
  end

  test "replacing a photo at quota preserves the other photos" do
    4.times do |index|
      @project.photos.attach(
        io: StringIO.new("image #{index}"),
        filename: "photo_#{index}.jpg",
        content_type: "image/jpeg"
      )
    end

    assert_equal 4, @project.photos.count

    original_attachments = @project.photos.attachments.to_a
    photo_to_remove = original_attachments.first

    kept_blob_ids = original_attachments.drop(1).map(&:blob_id)

    patch project_path(@project), params: {
      project: {
        name: @project.name,
        remove_photo_ids: [photo_to_remove.id.to_s],
        photos: [
          fixture_file_upload("test_image.jpg", "image/jpeg")
        ]
      }
    }

    assert_redirected_to project_path(@project)

    @project.reload

    assert_equal 4, @project.photos.count

    current_blob_ids = @project.photos.attachments.map(&:blob_id)

    assert (kept_blob_ids - current_blob_ids).empty?,
          "Les trois images conservées doivent toujours être présentes"

    refute_includes current_blob_ids, photo_to_remove.blob_id,
                    "L'image supprimée ne doit plus être associée au projet"
  end

  test "validation failure does not remove existing photos" do
    2.times do |index|
      @project.photos.attach(
        io: StringIO.new("image #{index}"),
        filename: "photo_#{index}.jpg",
        content_type: "image/jpeg"
      )
    end

    original_blob_ids = @project.photos.attachments.map(&:blob_id)
    photo_to_remove = @project.photos.attachments.first

    patch project_path(@project), params: {
      project: {
        name: "",
        remove_photo_ids: [photo_to_remove.id.to_s]
      }
    }

    assert_response :unprocessable_entity

    @project.reload

    assert_equal 2, @project.photos.count
    assert_equal original_blob_ids.sort,
                @project.photos.attachments.map(&:blob_id).sort
  end

  test "invalid upload does not remove existing photos" do
    2.times do |index|
      @project.photos.attach(
        io: StringIO.new("image #{index}"),
        filename: "photo_#{index}.jpg",
        content_type: "image/jpeg"
      )
    end

    original_blob_ids = @project.photos.attachments.map(&:blob_id)
    photo_to_remove = @project.photos.attachments.first

    invalid_file = Rack::Test::UploadedFile.new(
      StringIO.new("This is not an image"),
      "text/plain",
      original_filename: "invalid.txt"
    )

    patch project_path(@project), params: {
      project: {
        name: @project.name,
        remove_photo_ids: [photo_to_remove.id.to_s],
        photos: [invalid_file]
      }
    }

    assert_response :unprocessable_entity

    @project.reload

    assert_equal 2, @project.photos.count
    assert_equal original_blob_ids.sort,
                @project.photos.attachments.map(&:blob_id).sort
  end

  test "adding a fifth photo is rejected without losing existing photos" do
    4.times do |index|
      @project.photos.attach(
        io: StringIO.new("image #{index}"),
        filename: "photo_#{index}.jpg",
        content_type: "image/jpeg"
      )
    end

    original_blob_ids = @project.photos.attachments.map(&:blob_id)

    patch project_path(@project), params: {
      project: {
        name: @project.name,
        photos: [
          fixture_file_upload("test_image.jpg", "image/jpeg")
        ]
      }
    }

    assert_redirected_to edit_project_path(@project)

    @project.reload

    assert_equal 4, @project.photos.count
    assert_equal original_blob_ids.sort,
                @project.photos.attachments.map(&:blob_id).sort
  end

  test "invalid photo removal id is rejected" do
    @project.photos.attach(
      io: StringIO.new("image"),
      filename: "photo.jpg",
      content_type: "image/jpeg"
    )

    original_blob_ids = @project.photos.attachments.map(&:blob_id)

    patch project_path(@project), params: {
      project: {
        name: @project.name,
        remove_photo_ids: ["999999999"]
      }
    }

    assert_redirected_to edit_project_path(@project)

    @project.reload

    assert_equal 1, @project.photos.count
    assert_equal original_blob_ids,
                @project.photos.attachments.map(&:blob_id)
  end

  test "affiche un lien HTTPS valide avec les protections de securite" do
    @project.update!(url: "https://example.com")

    get project_path(@project)

    assert_response :success

    assert_select 'a[href="https://example.com"]',
                  text: /Visiter le site/,
                  count: 1

    assert_select 'a[href="https://example.com"][target="_blank"]',
                  count: 1

    assert_select 'a[href="https://example.com"][rel~="noopener"][rel~="noreferrer"]',
                  count: 1
  end

  test "ne genere pas de lien pour une URL dangereuse" do
    # Simule une ancienne URL dangereuse déjà enregistrée en base.
    # update_columns contourne volontairement les validations Rails.
    @project.update_columns(url: "javascript:alert(1)")

    get project_path(@project)

    assert_response :success

    assert_select 'a[href^="javascript:"]', count: 0
    assert_select 'a', text: /Visiter le site/, count: 0
  end

  test "non admin cannot edit a project" do
    user = User.create!(
      email: "user-pundit-test@example.com",
      password: "Password123!",
      admin: false
    )

    sign_out @admin
    sign_in user

    get edit_project_path(@project)

    assert_redirected_to root_path
    assert_equal "Vous n'êtes pas autorisé à effectuer cette action.",
                flash[:notice]
  end
end