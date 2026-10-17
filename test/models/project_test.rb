
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

  test "refuse les URL avec un hôte invalide ou ambigu" do
    [
      "https://?test=1",
      "https://:443",
      "https://example.com:abc",
      "https://example.com\\@evil.com",
      "https://user@example.com",
      "https://example.com:99999"
    ].each do |url|
      project = build_project(url)

      assert_not project.valid?,
        "#{url.inspect} devrait être refusée"

      assert project.errors[:url].any?,
        "#{url.inspect} devrait produire une erreur sur l'URL"
    end
  end

  test "refuse les noms d'hote mal formes" do
    [
      "https://-example.com",
      "https://example-.com",
      "https://example..com",
      "https://example.com-"
    ].each do |url|
      project = build_project(url)

      assert_not project.valid?,
        "#{url.inspect} devrait être refusée"
    end
  end

  test "accepte les noms d'hote et ports valides" do
    [
      "https://example.com.",
      "https://localhost:3000",
      "https://127.0.0.1:3000",
      "https://example.com:443"
    ].each do |url|
      project = build_project(url)

      assert project.valid?,
        "#{url.inspect} devrait être acceptée : #{project.errors.full_messages.join(', ')}"
    end
  end
end
