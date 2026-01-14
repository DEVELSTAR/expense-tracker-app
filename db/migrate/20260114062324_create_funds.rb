class CreateFunds < ActiveRecord::Migration[8.1]
  def change
    create_table :funds do |t|
      t.string :name, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false, default: 0
      t.references :admin, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :funds, :name
  end
end
