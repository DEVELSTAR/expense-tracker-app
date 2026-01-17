class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.references :user, foreign_key: true, null: true
      t.boolean :global, default: false, null: false
      t.timestamps
    end
  end
end
