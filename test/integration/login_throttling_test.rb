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
end