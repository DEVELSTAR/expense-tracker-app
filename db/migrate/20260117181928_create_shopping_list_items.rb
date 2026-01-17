class CreateShoppingListItems < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_list_items do |t|
      t.string :name, null: false
      t.boolean :completed, default: false, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
