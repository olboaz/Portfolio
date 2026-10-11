require "net/http"
require "json"

class TurnstileVerificationService
  API_URL = "https://challenges.cloudflare.com/turnstile/v0/siteverify".freeze

  def self.valid?(token, remote_ip = nil)
    return false if token.blank?

    uri = URI(API_URL)

    response = Net::HTTP.post_form(
      uri,
      {
        "secret" => ENV.fetch("TURNSTILE_SECRET_KEY"),
        "response" => token,
        "remoteip" => remote_ip
      }.compact
    )

    return false unless response.is_a?(Net::HTTPSuccess)

    result = JSON.parse(response.body)

    result["success"] == true
  rescue StandardError => e
    Rails.logger.error("Turnstile verification error: #{e.message}")
    false
  end
end