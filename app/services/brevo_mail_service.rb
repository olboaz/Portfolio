
require "net/http"
require "json"

class BrevoMailService
  API_URL = "https://api.brevo.com/v3/smtp/email".freeze

  def self.send_contact(contact)
    uri = URI(API_URL)

    payload = {
      sender: {
        name: "Portfolio",
        email: ENV.fetch("BREVO_SENDER_EMAIL")
      },
      # to: [
      #   { email: "contact@pjaszczynski.fr" }
      # ],
      to: [
        { email: "ppastg92@free.fr" }
      ],
      replyTo: {
        email: contact.email,
        name: contact.name
      },
      subject: "Demande de contact",
      textContent: <<~TEXT
        Nom : #{contact.name}
        Email : #{contact.email}

        Message :
        #{contact.message}
      TEXT
    }

    request = Net::HTTP::Post.new(uri)
    request["api-key"] = ENV.fetch("BREVO_API_KEY")
    request["Content-Type"] = "application/json"
    request.body = payload.to_json

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true
    ) { |http| http.request(request) }

    unless response.code.to_i.between?(200, 299)
      raise "Brevo API error (#{response.code}): #{response.body}"
    end

    response
  end
end
