class CreateTools < ActiveRecord::Migration[6.0]
  def change
    create_table :tools do |t|
      t.string :name
      t.string :tool_type, array: true
      t.timestamps
    end
  end
end
