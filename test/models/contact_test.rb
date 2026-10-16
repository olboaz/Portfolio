
require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def build_contact(email)
    Contact.new(
      name: "Jean Dupont",
      email: email,
      message: "Bonjour, ceci est un message de test."
    )
  end

  test "accepte une adresse email valide" do
    ["contact@example.com", "jean.dupont@example.fr", "contact@sub.example.com"].each do |email|
      contact = build_contact(email)

      assert contact.valid?, "#{email} devrait être valide : #{contact.errors.full_messages.join(', ')}"
    end
  end

  test "refuse une adresse email invalide" do
    [
      "adresse-invalide",
      "contact@",
      "@example.com",
      "contact@example",
      "contact@@example.com",
      "contact@example.com texte",
      "texte contact@example.com",
      "contact @example.com",
      "contact@example.com\nmalveillant"
    ].each do |email|
      contact = build_contact(email)

      assert_not contact.valid?, "#{email.inspect} devrait être refusée"
      assert contact.errors[:email].any?, "#{email.inspect} devrait produire une erreur sur email"
    end
  end

  test "refuse une adresse email vide" do
    contact = build_contact("")

    assert_not contact.valid?
    assert contact.errors[:email].any?
  end

  test "refuse une adresse email trop longue" do
    email = "#{'a' * 245}@example.com"
    contact = build_contact(email)

    assert_not contact.valid?
    assert contact.errors[:email].any?
  end
end
