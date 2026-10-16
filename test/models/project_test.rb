
require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def build_project(url)
    Project.new(
      name: "Projet de test",
      url: url
    )
  end

  test "accepte les URL HTTP et HTTPS" do
    [
      "https://example.com",
      "http://example.com",
      "https://example.com/projet",
      "https://sub.example.com/page?id=123",
      "https://example.com/#portfolio"
    ].each do |url|
      project = build_project(url)

      assert project.valid?,
        "#{url.inspect} devrait être valide : #{project.errors.full_messages.join(', ')}"
    end
  end

  test "refuse les protocoles dangereux" do
    [
      "javascript:alert(1)",
      "data:text/html,test",
      "file:///etc/passwd",
      "vbscript:alert(1)"
    ].each do |url|
      project = build_project(url)

      assert_not project.valid?, "#{url.inspect} devrait être refusée"
      assert project.errors[:url].any?
    end
  end

  test "refuse les URL mal formées" do
    [
      "example.com",
      "https://",
      "http://",
      "https://example.com texte",
      "https://example.com\njavascript:alert(1)"
    ].each do |url|
      project = build_project(url)

      assert_not project.valid?, "#{url.inspect} devrait être refusée"
      assert project.errors[:url].any?
    end
  end

  test "accepte un projet sans URL" do
    [nil, ""].each do |url|
      project = build_project(url)

      assert project.valid?, "Un projet sans URL devrait être valide"
    end
  end
end
