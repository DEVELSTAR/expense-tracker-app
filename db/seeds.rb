# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.

puts "🌱 Seeding database..."

# Create Admin user (only via seed, no API)
puts "\nCreating admin user..."
admin = User.find_or_initialize_by(email: "admin@expensetracker.com")
if admin.new_record?
  admin.name = "Admin"
  admin.password = "admin123456"
  admin.password_confirmation = "admin123456"
  admin.admin = true
  admin.save!
  puts "  ✓ Created admin: Admin (admin@expensetracker.com)"
else
  # Update existing admin to ensure admin flag is set
  admin.update!(admin: true) unless admin.admin?
  puts "  ✓ Admin already exists: #{admin.email}"
end

# Create sample users
puts "\nCreating sample users..."
users_data = [
  { name: "Rahul Sharma", email: "rahul@example.com", password: "password123" },
  { name: "Priya Sharma", email: "priya@example.com", password: "password123" }
]

users = users_data.map do |user_data|
  user = User.find_or_initialize_by(email: user_data[:email])
  if user.new_record?
    user.name = user_data[:name]
    user.password = user_data[:password]
    user.password_confirmation = user_data[:password]
    user.admin = false
    user.save!
    puts "  ✓ Created user: #{user.name} (#{user.email})"
  else
    puts "  ✓ User already exists: #{user.email}"
  end
  user
end

rahul, priya = users

# Create sample expenses
puts "\nCreating sample expenses..."

current_month = Date.current
last_month = Date.current.last_month

expenses_data = [
  # Rahul's current month expenses
  { user: rahul, amount: 2500.00, category: "groceries", note: "Weekly vegetables and fruits", spent_on: current_month.beginning_of_month + 5.days },
  { user: rahul, amount: 25000.00, category: "rent", note: "Monthly rent payment", spent_on: current_month.beginning_of_month + 1.day },
  { user: rahul, amount: 1500.00, category: "travel", note: "Uber rides this week", spent_on: current_month.beginning_of_month + 10.days },
  { user: rahul, amount: 3200.00, category: "bills", note: "Electricity bill", spent_on: current_month.beginning_of_month + 7.days },
  { user: rahul, amount: 4500.00, category: "shopping", note: "New clothes from mall", spent_on: current_month.beginning_of_month + 12.days },
  
  # Priya's current month expenses
  { user: priya, amount: 1800.00, category: "groceries", note: "Fresh produce from market", spent_on: current_month.beginning_of_month + 3.days },
  { user: priya, amount: 2200.00, category: "shopping", note: "Books and stationery", spent_on: current_month.beginning_of_month + 8.days },
  { user: priya, amount: 800.00, category: "travel", note: "Metro recharge", spent_on: current_month.beginning_of_month + 6.days },
  { user: priya, amount: 5000.00, category: "other", note: "Birthday gift for mom", spent_on: current_month.beginning_of_month + 11.days },
  
  # Last month expenses
  { user: rahul, amount: 2800.00, category: "groceries", note: "Monthly groceries", spent_on: last_month.beginning_of_month + 4.days },
  { user: rahul, amount: 25000.00, category: "rent", note: "Monthly rent", spent_on: last_month.beginning_of_month + 1.day },
  { user: priya, amount: 6500.00, category: "shopping", note: "Online shopping", spent_on: last_month.beginning_of_month + 15.days },
  { user: priya, amount: 4000.00, category: "travel", note: "Weekend trip fuel", spent_on: last_month.beginning_of_month + 20.days }
]

expenses_data.each do |expense_data|
  expense = expense_data[:user].expenses.create!(
    amount: expense_data[:amount],
    category: expense_data[:category],
    note: expense_data[:note],
    spent_on: expense_data[:spent_on]
  )
  puts "  ✓ Added expense: ₹#{format('%.2f', expense.amount)} - #{expense.category} (#{expense.user.name})"
end

puts "\n✅ Seeding complete!"
puts "\n📊 Summary:"
puts "  Users: #{User.count}"
puts "  Admins: #{User.admins.count}"
puts "  Expenses: #{Expense.count}"
puts "\n🔐 Login credentials:"
puts "  Admin: admin@expensetracker.com / admin123456"
puts "  User 1: rahul@example.com / password123"
puts "  User 2: priya@example.com / password123"
