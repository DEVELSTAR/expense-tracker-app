class AddRolesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string, default: "dependent"
    add_reference :users, :guardian, null: true, foreign_key: { to_table: :users }
    add_index :users, :role
  end
end
