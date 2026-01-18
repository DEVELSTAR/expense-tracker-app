# frozen_string_literal: true

puts "🌱 Seeding database..."

# ======================
# CREATE ADMIN USER
# ======================
puts "👑 Ensuring admin user..."

# Use Environment Variables from Render if available
admin_email = ENV["EMAIL_ADDRESS"].presence || "admin@expensetracker.com"
admin_password = ENV["PASSWORD"].presence || "password123"

# Find existing admin or create new one
User.find_or_create_by!(email: admin_email) do |u|
  u.name = "System Admin"
  u.password = admin_password
  u.password_confirmation = admin_password
  u.role = "admin"
  u.admin = true
  u.confirmed_at = Time.current
end

puts "   ✅ Admin user ensured: #{admin_email}"
puts "      (Password: #{ENV['PASSWORD'] ? '***Configured from Env***' : 'password123'})"

puts ""
puts "=" * 50
puts "🎉 Seeding completed!"
puts "=" * 50
