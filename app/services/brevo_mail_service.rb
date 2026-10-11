
require "net/http"
require "json"

class BrevoMailService
  API_URL = "https://api.brevo.com/v3/smtp/email".freeze

  def self.send_contact(contact, visitor_info: {})
    country_code = visitor_info[:country_code].to_s.upcase
    country_code = "??" unless country_code.match?(/\A[A-Z]{2}\z/)

    subject = "[Portfolio][#{country_code}] Demande de contact"

    technical_info = <<~TEXT
      INFORMATIONS TECHNIQUES
      -----------------------
      Adresse IP : #{visitor_info[:ip] || "Inconnue"}
      Pays : #{visitor_info[:country] || "Inconnu"} (#{country_code})
      Ville : #{visitor_info[:city] || "Inconnue"}
      Fournisseur : #{visitor_info[:isp] || "Inconnu"}
      ASN : #{visitor_info[:asn] || "Inconnu"}
      Hostname : #{visitor_info[:hostname] || "Non disponible"}
      Navigateur : #{visitor_info[:user_agent] || "Inconnu"}
      Langue : #{visitor_info[:language] || "Inconnue"}
      Provenance : #{visitor_info[:referer] || "Inconnue"}
      Date : #{visitor_info[:captured_at]&.strftime("%d/%m/%Y %H:%M:%S") || "Inconnue"}
    TEXT

    payload = {
      sender: {
        name: "Portfolio",
        email: ENV.fetch("BREVO_SENDER_EMAIL")
      },
      to: [
        { email: "ppastg92@free.fr" }
      ],
      replyTo: {
        email: contact.email,
        name: contact.name
      },
      subject: subject,
      textContent: <<~TEXT
        Nom : #{contact.name}
        Email : #{contact.email}

        Message :
        #{contact.message}

        -----------------------

        #{technical_info}
      TEXT
    }

    uri = URI(API_URL)

    request = Net::HTTP::Post.new(uri)
    request["api-key"] = ENV.fetch("BREVO_API_KEY")
    request["Content-Type"] = "application/json"
    request.body = payload.to_json

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true,
      open_timeout: 5,
      read_timeout: 10
    ) do |http|
      http.request(request)
    end

    unless response.code.to_i.between?(200, 299)
      raise "Brevo API error (#{response.code}): #{response.body}"
    end

    response
  end
end
