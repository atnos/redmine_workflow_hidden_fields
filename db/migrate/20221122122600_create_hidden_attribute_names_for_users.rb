class CreateHiddenAttributeNamesForUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :hidden_attribute_names_for_users do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.references :project, foreign_key: true
    end
  end
end
