class CreateRecurringExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :recurring_expenses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :fund, foreign_key: true
      t.references :category, foreign_key: true
      t.string :name, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :frequency, default: "monthly", null: false
      t.date :next_run_date, null: false
      t.text :note
      t.boolean :active, default: true, null: false
      t.timestamps
    end
    add_index :recurring_expenses, [ :user_id, :active ]
    add_index :recurring_expenses, :next_run_date
  end
end
