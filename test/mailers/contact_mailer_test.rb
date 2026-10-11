require 'test_helper'

class ContactMailerTest < ActionMailer::TestCase
  test "general_message prepares a contact email" do
    contact = Struct.new(:name, :email, :message).new(
      "Test User",
      "test@example.com",
      "Bonjour, ceci est un test."
    )

    mail = ContactMailer.general_message(contact)

    assert_equal "Demande de contact", mail.subject
    assert_equal ["contact@pjaszczynski.fr"], mail.to
  end
end