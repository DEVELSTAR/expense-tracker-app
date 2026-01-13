# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Create Users
puts "Creating users..."

husband = User.find_or_create_by!(email: "john@example.com") do |user|
  user.name = "John Doe"
  user.password = "password123"
  user.password_confirmation = "password123"
end
puts "  ✓ Created user: #{husband.name} (#{husband.email})"

wife = User.find_or_create_by!(email: "jane@example.com") do |user|
  user.name = "Jane Doe"
  user.password = "password123"
  user.password_confirmation = "password123"
end
puts "  ✓ Created user: #{wife.name} (#{wife.email})"

# Create Expenses for the current month
puts "\nCreating sample expenses..."

current_month_start = Date.current.beginning_of_month
last_month_start = 1.month.ago.beginning_of_month

expenses_data = [
  # Current month expenses
  { amount: 156.75, spent_by: :self_expense, category: "groceries", note: "Weekly groceries from Whole Foods", spent_on: current_month_start + 2.days },
  { amount: 1850.00, spent_by: :self_expense, category: "rent", note: "Monthly rent payment", spent_on: current_month_start + 1.day },
  { amount: 45.00, spent_by: :wife, category: "shopping", note: "New shoes", spent_on: current_month_start + 3.days },
  { amount: 120.00, spent_by: :self_expense, category: "bills", note: "Electricity bill", spent_on: current_month_start + 5.days },
  { amount: 89.99, spent_by: :wife, category: "shopping", note: "Birthday gift for mom", spent_on: current_month_start + 6.days },
  { amount: 65.50, spent_by: :self_expense, category: "travel", note: "Gas for the car", spent_on: current_month_start + 7.days },
  { amount: 32.00, spent_by: :wife, category: "groceries", note: "Fresh produce from farmer's market", spent_on: current_month_start + 8.days },
  { amount: 85.00, spent_by: :self_expense, category: "bills", note: "Internet bill", spent_on: current_month_start + 10.days },
  { amount: 200.00, spent_by: :wife, category: "shopping", note: "Winter jacket", spent_on: current_month_start + 11.days },
  { amount: 55.00, spent_by: :self_expense, category: "travel", note: "Uber rides this week", spent_on: current_month_start + 12.days },

  # Last month expenses
  { amount: 142.30, spent_by: :self_expense, category: "groceries", note: "Weekly groceries", spent_on: last_month_start + 5.days },
  { amount: 1850.00, spent_by: :self_expense, category: "rent", note: "Monthly rent payment", spent_on: last_month_start + 1.day },
  { amount: 78.00, spent_by: :wife, category: "shopping", note: "Kitchen supplies", spent_on: last_month_start + 8.days },
  { amount: 250.00, spent_by: :self_expense, category: "travel", note: "Weekend trip to the coast", spent_on: last_month_start + 15.days },
  { amount: 95.00, spent_by: :self_expense, category: "bills", note: "Phone bill", spent_on: last_month_start + 12.days },
  { amount: 180.00, spent_by: :wife, category: "other", note: "Gym membership", spent_on: last_month_start + 10.days },
  { amount: 45.00, spent_by: :self_expense, category: "groceries", note: "Snacks for movie night", spent_on: last_month_start + 20.days },
  { amount: 320.00, spent_by: :wife, category: "shopping", note: "New laptop bag and accessories", spent_on: last_month_start + 22.days },
]

expenses_data.each do |expense_data|
  expense = husband.expenses.create!(expense_data)
  puts "  ✓ Added expense: $#{format('%.2f', expense.amount)} - #{expense.category} (#{expense.spent_by_label})"
end

# Also create a few expenses for the wife's account
wife_expenses = [
  { amount: 42.50, spent_by: :wife, category: "groceries", note: "Organic vegetables", spent_on: current_month_start + 4.days },
  { amount: 75.00, spent_by: :self_expense, category: "other", note: "Book club subscription", spent_on: current_month_start + 9.days },
  { amount: 28.00, spent_by: :wife, category: "travel", note: "Bus pass", spent_on: current_month_start + 2.days },
]

wife_expenses.each do |expense_data|
  expense = wife.expenses.create!(expense_data)
  puts "  ✓ Added expense for #{wife.name}: $#{format('%.2f', expense.amount)} - #{expense.category}"
end

puts "\n✅ Seeding complete!"
puts "\n📊 Summary:"
puts "  Users: #{User.count}"
puts "  Expenses: #{Expense.count}"
puts "\n🔐 Login credentials:"
puts "  Husband: john@example.com / password123"
puts "  Wife: jane@example.com / password123"
