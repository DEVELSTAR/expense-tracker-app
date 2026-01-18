# frozen_string_literal: true

puts "🌱 Seeding database..."

# puts "🧹 Clearing existing data..."
# begin
#   ActivityLog.destroy_all if defined?(ActivityLog)
#   Expense.destroy_all
#   RecurringExpense.destroy_all
#   FundUser.destroy_all
#   Fund.destroy_all
#   Category.destroy_all
#   User.destroy_all
# rescue => e
#   puts "Warning during cleanup: #{e.message}"
# end

# # ======================
# # CREATE CATEGORIES
# # ======================
# puts "📂 Creating global categories..."
# categories_list = %w[groceries rent travel shopping bills other]
# categories_map = {}

# categories_list.each do |name|
#   cat = Category.create!(name: name, global: true)
#   categories_map[name] = cat
# end
# puts "   ✅ Created #{categories_list.count} global categories"

# ======================
# CREATE ADMIN USER
# ======================
puts "👑 Creating admin user..."
admin = User.create!(
  name: "STAR",
  email: "[EMAIL_ADDRESS]",
  password: "[PASSWORD]",
  password_confirmation: "[PASSWORD]",
  role: "admin",
  admin: true,
  confirmed_at: Time.current
)
puts "   ✅ Admin: #{admin.email}"

# # ======================
# # CREATE GUARDIAN USERS
# # ======================
# puts "👨‍👩‍👧‍👦 Creating guardian users..."

# guardian1 = User.create!(
#   name: "Anam pagal",
#   email: "anam@example.com",
#   password: "password123",
#   password_confirmation: "password123",
#   role: "guardian",
#   confirmed_at: Time.current
# )
# puts "   ✅ Guardian: #{guardian1.email}"

# guardian2 = User.create!(
#   name: "Ayan",
#   email: "ayan@example.com",
#   password: "password123",
#   password_confirmation: "password123",
#   role: "guardian",
#   confirmed_at: Time.current
# )
# puts "   ✅ Guardian: #{guardian2.email}"

# # ======================
# # CREATE INDEPENDENT USERS
# # ======================
# puts "🧑‍ Creating independent users..."

# independent1 = User.create!(
#   name: "Independent Isaac",
#   email: "isaac@example.com",
#   password: "password123",
#   password_confirmation: "password123",
#   role: "independent",
#   confirmed_at: Time.current
# )
# puts "   ✅ Independent: #{independent1.email}"

# independent2 = User.create!(
#   name: "Solo Sarah",
#   email: "sarah@example.com",
#   password: "password123",
#   password_confirmation: "password123",
#   role: "independent",
#   confirmed_at: Time.current
# )
# puts "   ✅ Independent: #{independent2.email}"

# # ======================
# # CREATE DEPENDENT USERS
# # ======================
# puts "👶 Creating dependent users..."

# # Dependents for Guardian 1
# dependent1 = User.create!(
#   name: "Rakib",
#   email: "rakib@example.com",
#   password: "password123",
#   password_confirmation: "password123",
#   role: "dependent",
#   guardian: guardian1,
#   confirmed_at: Time.current
# )
# puts "   ✅ Dependent: #{dependent1.email} (Guardian: #{guardian1.name})"

# dependent2 = User.create!(
#   name: "Nisha parveen",
#   email: "nisha@example.com",
#   password: "password123",
#   password_confirmation: "password123",
#   role: "dependent",
#   guardian: guardian1,
#   confirmed_at: Time.current
# )
# puts "   ✅ Dependent: #{dependent2.email} (Guardian: #{guardian1.name})"

# # Dependents for Guardian 2
# dependent3 = User.create!(
#   name: "Neha parveen",
#   email: "neha@example.com",
#   password: "password123",
#   password_confirmation: "password123",
#   role: "dependent",
#   guardian: guardian2,
#   confirmed_at: Time.current
# )
# puts "   ✅ Dependent: #{dependent3.email} (Guardian: #{guardian2.name})"

# # ======================
# # CREATE FUNDS
# # ======================
# puts "💰 Creating funds..."

# # Guardian 1's Funds
# fund1 = Fund.create!(
#   name: "Family Monthly Budget",
#   amount: 50000.00,
#   admin: guardian1
# )
# fund1.users << [ guardian1, dependent1, dependent2 ]
# puts "   ✅ Fund: #{fund1.name} (₹#{fund1.amount})"

# fund2 = Fund.create!(
#   name: "Emergency Fund",
#   amount: 25000.00,
#   admin: guardian1
# )
# fund2.users << guardian1
# puts "   ✅ Fund: #{fund2.name} (₹#{fund2.amount})"

# # Guardian 2's Funds
# fund3 = Fund.create!(
#   name: "Household Expenses",
#   amount: 30000.00,
#   admin: guardian2
# )
# fund3.users << [ guardian2, dependent3 ]
# puts "   ✅ Fund: #{fund3.name} (₹#{fund3.amount})"

# # Independent User's Funds
# fund4 = Fund.create!(
#   name: "Isaac Personal Savings",
#   amount: 15000.00,
#   admin: independent1
# )
# fund4.users << independent1
# puts "   ✅ Fund: #{fund4.name} (₹#{fund4.amount})"

# # ======================
# # CREATE SAMPLE EXPENSES
# # ======================
# puts "🧾 Creating sample expenses..."

# expense_notes = {
#   "groceries" => [ "Weekly vegetables", "Monthly ration", "Fruits and snacks", "Dairy products" ],
#   "rent" => [ "Monthly rent", "Maintenance fees", "Electricity bill advance" ],
#   "travel" => [ "Bus pass", "Fuel", "Train tickets", "Uber/Ola rides" ],
#   "shopping" => [ "Clothes", "Electronics", "Home appliances", "Books" ],
#   "bills" => [ "Mobile recharge", "Internet bill", "Netflix subscription", "Electricity" ],
#   "other" => [ "Medical expenses", "School fees", "Gifts", "Miscellaneous" ]
# }

# users_list = [ guardian1, guardian2, dependent1, dependent2, dependent3, independent1, independent2 ]

# # Create expenses
# users_list.each do |user|
#   3.times do |month_offset|
#     date_range = (Date.current - month_offset.months).beginning_of_month...(Date.current - month_offset.months).end_of_month

#     rand(3..8).times do
#       category_name = categories_list.sample
#       category = categories_map[category_name]

#       # Determine fund usage
#       fund = nil
#       if user.funds.any? && rand < 0.5
#         valid_funds = user.funds.select { |f| f.remaining_balance > 500 }
#         fund = valid_funds.sample if valid_funds.any?
#       end

#       # Create Expense
#       Expense.create!(
#         user: user,
#         fund: fund,
#         amount: rand(100..2000).round(2),
#         category: category,
#         note: expense_notes[category_name]&.sample || "Direct expense",
#         spent_on: rand(date_range)
#       )
#     end
#   end
#   puts "   ✅ Created expenses for #{user.name}"
# end

# puts ""
# puts "=" * 50
# puts "🎉 Seeding completed!"
# puts "=" * 50
# puts ""
# puts "📊 Summary:"
# puts "   • Categories: #{Category.count}"
# puts "   • Users: #{User.count}"
# puts "   • Funds: #{Fund.count}"
# puts "   • Expenses: #{Expense.count}"
