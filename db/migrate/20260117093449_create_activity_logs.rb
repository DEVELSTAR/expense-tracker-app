class CreateActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action
      t.references :trackable, polymorphic: true, null: false
      t.jsonb :details
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
