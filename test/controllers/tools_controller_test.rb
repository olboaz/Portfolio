require "test_helper"

class ToolsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(
      email: "admin-tools-test@example.com",
      password: "Password123!",
      admin: true
    )

    @user = User.create!(
      email: "user-tools-test@example.com",
      password: "Password123!",
      admin: false
    )

    @tool = Tool.create!(
      name: "Outil Pundit Test"
    )
  end

  test "non admin cannot destroy a tool" do
    sign_in @user

    assert_no_difference "Tool.count" do
      delete tool_path(@tool)
    end

    assert_redirected_to root_path
    assert_equal "Vous n'êtes pas autorisé à effectuer cette action.",
                 flash[:notice]

    assert Tool.exists?(@tool.id)
  end
end