# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_14_164658) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "expenses", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.bigint "fund_id"
    t.text "note"
    t.date "spent_on", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category"], name: "index_expenses_on_category"
    t.index ["fund_id"], name: "index_expenses_on_fund_id"
    t.index ["spent_on"], name: "index_expenses_on_spent_on"
    t.index ["user_id"], name: "index_expenses_on_user_id"
  end

  create_table "fund_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "fund_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["fund_id", "user_id"], name: "index_fund_users_on_fund_id_and_user_id", unique: true
    t.index ["fund_id"], name: "index_fund_users_on_fund_id"
    t.index ["user_id"], name: "index_fund_users_on_user_id"
  end

  create_table "funds", force: :cascade do |t|
    t.bigint "admin_id", null: false
    t.decimal "amount", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_funds_on_admin_id"
    t.index ["name"], name: "index_funds_on_name"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.bigint "guardian_id"
    t.string "guardian_uid"
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "dependent"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["guardian_id"], name: "index_users_on_guardian_id"
    t.index ["guardian_uid"], name: "index_users_on_guardian_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "expenses", "funds"
  add_foreign_key "expenses", "users"
  add_foreign_key "fund_users", "funds"
  add_foreign_key "fund_users", "users"
  add_foreign_key "funds", "users", column: "admin_id"
  add_foreign_key "users", "users", column: "guardian_id"
end
