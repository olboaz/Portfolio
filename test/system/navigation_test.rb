require "application_system_test_case"

class NavigationTest < ApplicationSystemTestCase
  test "la page d'accueil est accessible" do
    visit root_path

    assert_selector "body"
    assert_selector "title", visible: :all
  end

  test "navigation vers la politique de confidentialité" do
    visit root_path

    execute_script("document.documentElement.dataset.navigationTest = 'preserved'")

    click_link "Politique de confidentialité"

    assert_current_path privacy_path
    assert_equal "preserved", evaluate_script("document.documentElement.dataset.navigationTest")
    assert_selector "body"
    assert_text "Politique de confidentialité"
  end

end
