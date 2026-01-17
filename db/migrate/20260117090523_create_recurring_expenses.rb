class CreateRecurringExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :recurring_expenses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :fund, null: true, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :category, null: false
      t.text :note
      t.string :frequency, null: false, default: 'monthly'
      t.date :next_run_date, null: false
      t.boolean :active, default: true, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :recurring_expenses, [ :user_id, :active ]
    add_index :recurring_expenses, :next_run_date
  end
end
