namespace :db do
  desc "Kill all connections to the database to allow dropping"
  task kill_connections: :environment do
    db_name = ActiveRecord::Base.connection.current_database
    puts "Attempting to kill connections to #{db_name}..."

    sql = <<~SQL
      SELECT pg_terminate_backend(pid)
      FROM pg_stat_activity
      WHERE datname = '#{db_name}'
        AND pid <> pg_backend_pid();
    SQL

    begin
      ActiveRecord::Base.connection.execute(sql)
      puts "✅ Killed all other connections."
    rescue => e
      puts "⚠️  Error killing connections: #{e.message}"
    end
  end
end
