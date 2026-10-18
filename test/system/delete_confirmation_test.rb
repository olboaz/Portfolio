require "application_system_test_case"

class DeleteConfirmationTest < ApplicationSystemTestCase
  test "annuler une confirmation bloque la suppression" do
    visit root_path

    execute_script <<~JS
      const form = document.createElement("form");
      form.method = "post";
      form.action = "/projects/999999999";
      form.dataset.turboConfirm = "Confirmer la suppression ?";

      const method = document.createElement("input");
      method.type = "hidden";
      method.name = "_method";
      method.value = "delete";
      form.appendChild(method);

      const button = document.createElement("button");
      button.type = "submit";
      button.textContent = "Supprimer le projet test";
      form.appendChild(button);

      document.body.appendChild(form);
    JS

    original_path = current_path

    dismiss_confirm("Confirmer la suppression ?") do
      click_button "Supprimer le projet test"
    end

    assert_current_path original_path
    assert_selector "button", text: "Supprimer le projet test"
  end
end
