require "test_helper"
require "rake"

class ContactsCleanupTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("contacts:cleanup")
  end

  test "supprime uniquement les contacts de plus de 90 jours" do
    old_contact = Contact.create!(
      name: "Ancien contact",
      email: "ancien@example.com",
      message: "Message ancien",
      created_at: 100.days.ago
    )

    recent_contact = Contact.create!(
      name: "Contact récent",
      email: "recent@example.com",
      message: "Message récent",
      created_at: 30.days.ago
    )

    assert_difference("Contact.count", -1) do
      Rake::Task["contacts:cleanup"].reenable
      Rake::Task["contacts:cleanup"].invoke
    end

    assert_not Contact.exists?(old_contact.id),
               "Le contact ancien doit être supprimé"

    assert Contact.exists?(recent_contact.id),
           "Le contact récent doit être conservé"
  end
end