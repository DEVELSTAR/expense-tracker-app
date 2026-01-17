class CreateActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action
      t.string :trackable_type, null: false
      t.bigint :trackable_id, null: false
      t.jsonb :details
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end
    add_index :activity_logs, [ :trackable_type, :trackable_id ]
  end
end
