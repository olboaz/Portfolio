require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "unauthenticated visitor is redirected to login" do
    get admin_index_url

    assert_redirected_to new_user_session_path
  end

  test "authenticated non-admin user cannot access dashboard" do
    user = create_test_user(admin: false)

    sign_in user
    get admin_index_url

    assert_redirected_to root_path
  end

  test "authenticated admin can access dashboard" do
    user = create_test_user(admin: true)

    sign_in user
    get admin_index_url

    assert_response :success
  end

  test "admin session expires after 30 minutes of inactivity" do
    user = create_test_user(admin: true)

    sign_in user

    # L'administrateur peut accéder au tableau de bord.
    get admin_index_url
    assert_response :success

    # On simule 31 minutes d'inactivité.
    travel 31.minutes do
      get admin_index_url

      # La session a expiré : retour à la connexion.
      assert_redirected_to new_user_session_path
    end
  end

  private

  def create_test_user(admin:)
    User.create!(
      email: "test-#{admin ? 'admin' : 'user'}@example.com",
      password: "TestPassword123!",
      password_confirmation: "TestPassword123!",
      admin: admin
    )
  end
end