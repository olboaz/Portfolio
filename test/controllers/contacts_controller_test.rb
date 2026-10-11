require "test_helper"
require "minitest/mock"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  test "une panne GeoIP n'empeche pas l'envoi Brevo" do
    brevo_called = false
    received_visitor_info = nil

    contact_params = {
      name: "Test GeoIP",
      email: "geoip@example.com",
      message: "Test de panne du service GeoIP."
    }

    TurnstileVerificationService.stub(:valid?, true) do
      ContactVisitorInfoService.stub(
        :call,
        ->(*) { raise StandardError, "Service GeoIP indisponible" }
      ) do
        BrevoMailService.stub(
          :send_contact,
          ->(contact, visitor_info: {}) {
            brevo_called = true
            received_visitor_info = visitor_info

            assert_equal "geoip@example.com", contact.email

            Struct.new(:code).new("201")
          }
        ) do
          assert_difference("Contact.count", 1) do
            post contacts_path, params: {
              contact: contact_params,
              "cf-turnstile-response" => "test-token"
            }
          end
        end
      end
    end

    assert brevo_called, "Brevo doit être appelé malgré la panne GeoIP"
    assert_equal({}, received_visitor_info)
    assert_redirected_to root_path
    assert_equal(
      "Merci pour votre message ! Je reviens vers vous rapidement.",
      flash[:notice]
    )
  end
end