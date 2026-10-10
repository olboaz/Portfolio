class ContactsController < ApplicationController
  skip_before_action :authenticate_user!, only: :create
  skip_after_action :verify_authorized, only: :create

def create
  @contact = Contact.new(contact_params)

  if @contact.save
    begin
      Rails.logger.info("BREVO : début de l'envoi")
      response = BrevoMailService.send_contact(@contact)
      Rails.logger.info("BREVO : réponse HTTP #{response.code}")
      flash[:notice] = "Merci pour votre message ! Je reviens vers vous rapidement."
    rescue StandardError => e
      Rails.logger.error("Erreur envoi Brevo : #{e.message}")
      flash[:notice] = "Votre message a bien été enregistré. Merci !"
    end

    redirect_to root_path
  else
    redirect_to root_path(
      anchor: 'contact',
      contact_info: {
        name: @contact.name,
        email: @contact.email,
        message: @contact.message,
        errors: @contact.errors.messages
      }
    )
  end
end

private

def contact_params
  params.require(:contact).permit(:name, :email, :message)
end
end
