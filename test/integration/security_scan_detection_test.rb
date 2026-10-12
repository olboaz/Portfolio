require "test_helper"
require "minitest/mock"

class SecurityScanDetectionTest < ActionDispatch::IntegrationTest
  test "detects suspicious paths without changing HTTP responses" do
    suspicious_paths = [
      "/api/v1/login",
      "/api/v1/auto_login",
      "/api/v1/users/",
      "/wp-admin",
      "/wp-login.php",
      "/.env",
      "/.git/config"
    ]

    suspicious_paths.each do |path|
      assert_logged_scan(path)
    end
  end

  test "sends only one Slack alert for repeated scans" do
    Rack::Attack.cache.store.clear

    assert_enqueued_jobs 1, only: SecuritySlackNotificationJob do
      get "/wp-login.php"
      assert_response :not_found

      get "/.env"
      assert_response :not_found

      get "/.git/config"
      assert_response :not_found
    end
  ensure
    Rack::Attack.cache.store.clear
  end

  test "limits scan Slack alerts to 10 per hour globally" do
    Rack::Attack.cache.store.clear

    global_key = "security:slack:global:#{Time.current.to_i / 3600}"

    # Simule 10 alertes déjà comptabilisées
    Rack::Attack.cache.store.write(
      global_key,
      10,
      expires_in: 1.hour
    )

    assert_no_enqueued_jobs only: SecuritySlackNotificationJob do
      get "/wp-login.php"
      assert_response :not_found
    end

    assert_equal 11, Rack::Attack.cache.store.read(global_key)
  ensure
    Rack::Attack.cache.store.clear
  end

  test "shares the global Slack alert limit with login protection" do
    Rack::Attack.cache.store.clear

    global_key = "security:slack:global:#{Time.current.to_i / 3600}"

    # Simule 9 alertes déjà envoyées
    Rack::Attack.cache.store.write(
      global_key,
      9,
      expires_in: 1.hour
    )

    # Un scan utilise la dernière notification disponible
    assert_enqueued_jobs 1, only: SecuritySlackNotificationJob do
      get "/wp-login.php"
      assert_response :not_found
    end

    assert_equal 10, Rack::Attack.cache.store.read(global_key)

    # Une connexion bloquée ne doit plus générer d'alerte
    assert_no_enqueued_jobs only: SecuritySlackNotificationJob do
      6.times do
        post "/users/sign_in", params: {
          user: {
            email: "unknown@example.com",
            password: "incorrect"
          }
        }
      end

      assert_response :too_many_requests
    end

    assert_equal 11, Rack::Attack.cache.store.read(global_key)
  ensure
    Rack::Attack.cache.store.clear
  end

  private

  def assert_logged_scan(path)
    messages = []

    Rails.logger.stub(:warn, ->(message) { messages << message }) do
      get path
    end

    assert_response :not_found
    assert(
      messages.any? { |message| message.include?("[SecurityScan]") },
      "Aucun scan détecté pour #{path}"
    )
  end
end