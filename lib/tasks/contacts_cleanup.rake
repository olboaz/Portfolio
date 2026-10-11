namespace :contacts do
  desc "Supprime les contacts de plus de 90 jours"
  task cleanup: :environment do
    cutoff = 90.days.ago

    scope = Contact.where("created_at < ?", cutoff)
    count = scope.count

    puts "[Contacts Cleanup] Date limite : #{cutoff}"
    puts "[Contacts Cleanup] Contacts à supprimer : #{count}"

    if count.positive?
      deleted = scope.delete_all
      puts "[Contacts Cleanup] Contacts supprimés : #{deleted}"
    else
      puts "[Contacts Cleanup] Aucun nettoyage nécessaire"
    end
  end
end