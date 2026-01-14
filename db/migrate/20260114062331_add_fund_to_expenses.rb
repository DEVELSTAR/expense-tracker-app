class AddFundToExpenses < ActiveRecord::Migration[8.1]
  def change
    add_reference :expenses, :fund, null: true, foreign_key: true
  end
end
