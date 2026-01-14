class RemoveSpentByFromExpenses < ActiveRecord::Migration[8.1]
  def change
    remove_column :expenses, :spent_by, :integer
  end
end
