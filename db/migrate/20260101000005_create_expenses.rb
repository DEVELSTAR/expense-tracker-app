class CreateExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :fund, foreign_key: true
      t.references :category, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :note
      t.date :spent_on, null: false
      t.timestamps
    end
    add_index :expenses, :spent_on
  end
end
