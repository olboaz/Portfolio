class ChangeContactMessageToText < ActiveRecord::Migration[7.2]
  def change
    change_column :contacts, :message, :text
  end
end
