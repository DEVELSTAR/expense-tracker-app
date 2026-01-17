class AddAssignedByToFundUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :fund_users, :assigned_by, null: true, foreign_key: { to_table: :users }
    add_column :fund_users, :assigned_at, :datetime
  end
end
