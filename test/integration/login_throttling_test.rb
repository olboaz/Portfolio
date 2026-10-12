require "test_helper"

class LoginThrottlingTest < ActionDispatch::IntegrationTest
  setup do
    Rack::Attack.cache.store.clear
  end

  teardown do
    Rack::Attack.cache.store.clear
  end

  test "limits repeated login attempts" do
    5.times do
      post user_session_path, params: {
        user: {
          email: "unknown@example.com",
          password: "incorrect-password"
        }
      }

      assert_not_equal 429, response.status
    end

    post user_session_path, params: {
      user: {
        email: "unknown@example.com",
        password: "incorrect-password"
      }
    }

    assert_response :too_many_requests
  end

  test "sends only one Slack alert for repeated blocked logins" do
    Rack::Attack.cache.store.clear

    assert_no_enqueued_jobs only: SecuritySlackNotificationJob do
      5.times do
        post "/users/sign_in", params: {
          user: {
            email: "unknown@example.com",
            password: "incorrect"
          }
        }
      end
    end

    assert_enqueued_jobs 1, only: SecuritySlackNotificationJob do
      post "/users/sign_in", params: {
        user: {
          email: "unknown@example.com",
          password: "incorrect"
        }
      }

      assert_response :too_many_requests

      post "/users/sign_in", params: {
        user: {
          email: "unknown@example.com",
          password: "incorrect"
        }
      }

      assert_response :too_many_requests
    end
  ensure
    Rack::Attack.cache.store.clear
  end

  test "limits Slack alerts to 10 per hour globally" do
    Rack::Attack.cache.store.clear

    # Simule 10 alertes déjà comptabilisées pendant l'heure
    global_key = "security:slack:global:#{Time.current.to_i / 3600}"

    Rack::Attack.cache.store.write(
      global_key,
      10,
      expires_in: 1.hour
    )

    # La sixième tentative de connexion doit être bloquée,
    # sans programmer de notification supplémentaire.
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
  ensure
    Rack::Attack.cache.store.clear
  end
end