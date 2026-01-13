class CreateExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :spent_by, null: false, default: 0
      t.string :category, null: false
      t.text :note
      t.date :spent_on, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :expenses, :spent_on
    add_index :expenses, :spent_by
    add_index :expenses, :category
  end
end
