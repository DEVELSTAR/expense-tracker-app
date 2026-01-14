class AddGuardianUidToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :guardian_uid, :string
    add_index :users, :guardian_uid, unique: true
  end
end
