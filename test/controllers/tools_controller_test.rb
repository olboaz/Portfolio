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

  test "admin can create a tool with multiple categories" do
    sign_in @admin

    assert_difference "Tool.count", 1 do
      post tools_path, params: {
        tool: {
          name: "Outil catégories test",
          tool_type: "data analyse, data visualisation, data analyse"
        }
      }
    end

    tool = Tool.order(:id).last

    assert_equal [
      "data analyse",
      "data visualisation"
    ], tool.tool_type

    assert_redirected_to tool_path(tool)
  end

  test "admin can update tool categories" do
    sign_in @admin

    patch tool_path(@tool), params: {
      tool: {
        tool_type: "développement, design, , développement"
      }
    }

    assert_redirected_to tool_path(@tool)

    @tool.reload

    assert_equal [
      "développement",
      "design"
    ], @tool.tool_type
  end
end