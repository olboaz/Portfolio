class ContactsController < ApplicationController
  skip_before_action :authenticate_user!, only: :create
  skip_after_action :verify_authorized, only: :create


def create
  unless TurnstileVerificationService.valid?(
    params["cf-turnstile-response"],
    request.remote_ip
  )
    flash[:alert] = "La vérification anti-spam a échoué. Veuillez réessayer."
    return redirect_to root_path(anchor: "contact")
  end

  @contact = Contact.new(contact_params)

  if @contact.save
    begin
      # Récupération des informations techniques du visiteur
      # Ces informations ne sont pas enregistrées en base.
      visitor_info = begin
        ContactVisitorInfoService.call(request)
      rescue StandardError => e
        Rails.logger.warn(
          "Informations visiteur indisponibles : #{e.class}"
        )
        {}
      end

      Rails.logger.info("BREVO : début de l'envoi")

      response = BrevoMailService.send_contact(
        @contact,
        visitor_info: visitor_info
      )

      Rails.logger.info("BREVO : réponse HTTP #{response.code}")

      flash[:notice] = "Merci pour votre message ! Je reviens vers vous rapidement."

    rescue StandardError => e
      Rails.logger.error("Erreur envoi Brevo : #{e.message}")
      flash[:notice] = "Votre message a bien été enregistré. Merci !"
    end

    redirect_to root_path
  else
    redirect_to root_path(
      anchor: "contact",
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
