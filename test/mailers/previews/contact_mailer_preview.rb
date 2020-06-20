# Preview all emails at http://localhost:3000/rails/mailers/contact_mailer
class ContactMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/contact_mailer/general_message
  def general_message
    contact = Contact.new
    ContactMailer.general_message(contact)
  end
end
