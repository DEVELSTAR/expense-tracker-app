# frozen_string_literal: true

# This file contains seed data for developing and testing the expense tracker application.
# Run with: rails db:seed

puts "🌱 Seeding database..."

# Clear existing data (in development only)
if Rails.env.development?
  puts "🧹 Clearing existing data..."
  Expense.destroy_all
  FundUser.destroy_all
  Fund.destroy_all
  User.destroy_all
end

# ======================
# CREATE ADMIN USER
# ======================
puts "👑 Creating admin user..."
admin = User.create!(
  name: "System Admin",
  email: "admin@expensetracker.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin"
)
puts "   ✅ Admin: #{admin.email} (password: password123)"

# ======================
# CREATE GUARDIAN USERS
# ======================
puts "👨‍👩‍👧‍👦 Creating guardian users..."

guardian1 = User.create!(
  name: "Rajesh Kumar",
  email: "rajesh@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "guardian"
)
puts "   ✅ Guardian: #{guardian1.email}"

guardian2 = User.create!(
  name: "Priya Sharma",
  email: "priya@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "guardian"
)
puts "   ✅ Guardian: #{guardian2.email}"

# ======================
# CREATE DEPENDENT USERS
# ======================
puts "👶 Creating dependent users..."

# Dependents for Guardian 1 (Rajesh)
dependent1 = User.create!(
  name: "Arjun Kumar",
  email: "arjun@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "dependent",
  guardian: guardian1
)
puts "   ✅ Dependent: #{dependent1.email} (Guardian: #{guardian1.name})"

dependent2 = User.create!(
  name: "Meera Kumar",
  email: "meera@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "dependent",
  guardian: guardian1
)
puts "   ✅ Dependent: #{dependent2.email} (Guardian: #{guardian1.name})"

# Dependents for Guardian 2 (Priya)
dependent3 = User.create!(
  name: "Rohan Sharma",
  email: "rohan@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "dependent",
  guardian: guardian2
)
puts "   ✅ Dependent: #{dependent3.email} (Guardian: #{guardian2.name})"

# ======================
# CREATE FUNDS
# ======================
puts "💰 Creating funds..."

# Guardian 1's Funds
fund1 = Fund.create!(
  name: "Family Monthly Budget",
  amount: 50000.00,
  admin: guardian1
)
fund1.users << [ guardian1, dependent1, dependent2 ]
puts "   ✅ Fund: #{fund1.name} (₹#{fund1.amount})"

fund2 = Fund.create!(
  name: "Emergency Fund",
  amount: 25000.00,
  admin: guardian1
)
fund2.users << guardian1
puts "   ✅ Fund: #{fund2.name} (₹#{fund2.amount})"

# Guardian 2's Funds
fund3 = Fund.create!(
  name: "Household Expenses",
  amount: 30000.00,
  admin: guardian2
)
fund3.users << [ guardian2, dependent3 ]
puts "   ✅ Fund: #{fund3.name} (₹#{fund3.amount})"

# ======================
# CREATE SAMPLE EXPENSES
# ======================
puts "🧾 Creating sample expenses..."

categories = %w[groceries rent travel shopping bills other]
expense_notes = {
  "groceries" => [ "Weekly vegetables", "Monthly ration", "Fruits and snacks", "Dairy products" ],
  "rent" => [ "Monthly rent", "Maintenance fees", "Electricity bill advance" ],
  "travel" => [ "Bus pass", "Fuel", "Train tickets", "Uber/Ola rides" ],
  "shopping" => [ "Clothes", "Electronics", "Home appliances", "Books" ],
  "bills" => [ "Mobile recharge", "Internet bill", "Netflix subscription", "Electricity" ],
  "other" => [ "Medical expenses", "School fees", "Gifts", "Miscellaneous" ]
}

# Create expenses for the last 3 months
[ guardian1, guardian2, dependent1, dependent2, dependent3 ].each do |user|
  3.times do |month_offset|
    date_range = (Date.current - month_offset.months).beginning_of_month...(Date.current - month_offset.months).end_of_month

    # Create 3-5 expenses per month per user
    rand(3..5).times do
      category = categories.sample

      # Only assign fund sometimes and only for current month to keep more balance
      fund = nil
      if month_offset == 0 && rand < 0.3
        user_funds = user.funds.select { |f| f.remaining_balance > 500 }
        fund = user_funds.sample if user_funds.any?
      end

      # Use smaller amounts
      Expense.create!(
        user: user,
        fund: fund,
        amount: rand(100..500).round(2),
        category: category,
        note: expense_notes[category].sample,
        spent_on: rand(date_range)
      )
    end
  end
  puts "   ✅ Created expenses for #{user.name}"
end

# ======================
# SUMMARY
# ======================
puts ""
puts "=" * 50
puts "🎉 Seeding completed!"
puts "=" * 50
puts ""
puts "📊 Summary:"
puts "   • Admins: #{User.admins.count}"
puts "   • Guardians: #{User.guardians.count}"
puts "   • Dependents: #{User.dependents_role.count}"
puts "   • Funds: #{Fund.count}"
puts "   • Expenses: #{Expense.count}"
puts ""
puts "🔑 Login Credentials (all use password: password123):"
puts "   • Admin: admin@expensetracker.com"
puts "   • Guardian 1: rajesh@example.com (UID: #{guardian1.guardian_uid})"
puts "   • Guardian 2: priya@example.com (UID: #{guardian2.guardian_uid})"
puts "   • Dependent 1: arjun@example.com (Guardian: Rajesh)"
puts "   • Dependent 2: meera@example.com (Guardian: Rajesh)"
puts "   • Dependent 3: rohan@example.com (Guardian: Priya)"
puts ""
puts "🔗 Guardian UIDs for testing dependent registration:"
puts "   • Rajesh Kumar: #{guardian1.guardian_uid}"
puts "   • Priya Sharma: #{guardian2.guardian_uid}"
puts ""
