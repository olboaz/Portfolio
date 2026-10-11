
require "test_helper"
require "minitest/mock"
require "ostruct"
require "json"
require "net/http"

class BrevoMailServiceTest < ActiveSupport::TestCase
  def setup
    @contact = OpenStruct.new(
      name: "Contact Test",
      email: "test@example.com",
      message: "Bonjour, ceci est un test."
    )

    @visitor_info = {
      ip: "8.8.8.8",
      country: "United States",
      country_code: "US",
      city: "Mountain View",
      isp: "Google LLC",
      asn: 15169,
      hostname: "dns.google",
      user_agent: "Chrome / Windows",
      language: "fr-FR",
      referer: "https://www.google.com",
      captured_at: Time.zone.parse("2026-10-11 18:30:00")
    }
  end

  test "email contient les informations du visiteur" do
    payload = capture_brevo_payload(@visitor_info)

    assert_equal "[Portfolio][US] Demande de contact", payload["subject"]

    content = payload["textContent"]

    assert_includes content, "Contact Test"
    assert_includes content, "test@example.com"
    assert_includes content, "Bonjour, ceci est un test."
    assert_includes content, "8.8.8.8"
    assert_includes content, "United States (US)"
    assert_includes content, "Google LLC"
    assert_includes content, "15169"
    assert_includes content, "dns.google"
    assert_includes content, "Chrome / Windows"
    assert_includes content, "fr-FR"
  end

  test "pays inconnu utilise le code ??" do
    payload = capture_brevo_payload(
      @visitor_info.merge(country: "Inconnu", country_code: "??")
    )

    assert_equal "[Portfolio][??] Demande de contact", payload["subject"]
    assert_includes payload["textContent"], "Pays : Inconnu (??)"
  end

  private

  def capture_brevo_payload(visitor_info)
    captured_payload = nil

    fake_http = Object.new

    fake_http.define_singleton_method(:request) do |request|
      captured_payload = JSON.parse(request.body)
      Struct.new(:code).new("201")
    end

    ENV.stub(:fetch, ->(key, *args) {
      case key
      when "BREVO_SENDER_EMAIL" then "portfolio@example.com"
      when "BREVO_API_KEY" then "test-api-key"
      else
        raise KeyError, "Variable inconnue : #{key}"
      end
    }) do
      Net::HTTP.stub(:start, ->(*args, **kwargs, &block) {
        block.call(fake_http)
      }) do
        BrevoMailService.send_contact(
          @contact,
          visitor_info: visitor_info
        )
      end
    end

    captured_payload
  end
end
