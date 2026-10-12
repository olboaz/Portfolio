require "test_helper"
require "minitest/mock"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rack::Attack.reset!
  end
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

  test "une erreur de validation ne divulgue pas les donnees dans l URL" do
    contact_params = {
      name: "Visiteur Confidentiel",
      email: "email-invalide",
      message: "Message personnel confidentiel"
    }

    TurnstileVerificationService.stub(:valid?, true) do
      assert_no_difference("Contact.count") do
        post contacts_path, params: {
          contact: contact_params,
          "cf-turnstile-response" => "test-token"
        }
      end
    end

    assert_response :unprocessable_entity

    assert_equal "/contacts", request.path
    assert_nil response.headers["Location"]

    assert_select 'input[name="contact[name]"][value="Visiteur Confidentiel"]'
    assert_select 'input[name="contact[email]"][value="email-invalide"]'
    assert_select 'textarea[name="contact[message]"]',
                  text: /Message personnel confidentiel/
    assert_select ".invalid-feedback", text: /format de l.email non valide/
  end

  test "un message trop long est refuse sans erreur serveur" do
    long_message = "A" * 10_000

    TurnstileVerificationService.stub(:valid?, true) do
      assert_no_difference("Contact.count") do
        post contacts_path, params: {
          contact: {
            name: "Test Long",
            email: "test@example.com",
            message: long_message
          },
          "cf-turnstile-response" => "test-token"
        }
      end
    end

    assert_response :unprocessable_entity

    assert_select ".invalid-feedback",
                  text: /ne peut pas dépasser 2000 caractères/
  end

  test "un message unicode trop long ne provoque pas de CookieOverflow" do
    long_message = "🔥" * 10_000

    TurnstileVerificationService.stub(:valid?, true) do
      assert_no_difference("Contact.count") do
        post contacts_path, params: {
          contact: {
            name: "Test Unicode",
            email: "test@example.com",
            message: long_message
          },
          "cf-turnstile-response" => "test-token"
        }
      end
    end

    assert_response :unprocessable_entity

    assert_select ".invalid-feedback",
                  text: /ne peut pas dépasser 2000 caractères/
  end
end
