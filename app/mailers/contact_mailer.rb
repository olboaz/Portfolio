class ContactMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.contact_mailer.message.subject
  #
  def general_message(contact)
    @contact = contact # Instance variable => available in view
    mail(to: 'contact@pjaszczynski.fr', subject: 'Demande de contact')
  end
end
