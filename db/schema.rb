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

ActiveRecord::Schema[8.1].define(version: 2026_01_17_093820) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_logs", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.jsonb "details"
    t.string "ip_address"
    t.bigint "trackable_id", null: false
    t.string "trackable_type", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["trackable_type", "trackable_id"], name: "index_activity_logs_on_trackable"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

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
    t.datetime "assigned_at"
    t.bigint "assigned_by_id"
    t.datetime "created_at", null: false
    t.bigint "fund_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["assigned_by_id"], name: "index_fund_users_on_assigned_by_id"
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

  create_table "recurring_expenses", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.string "frequency", default: "monthly", null: false
    t.bigint "fund_id"
    t.string "name", null: false
    t.date "next_run_date", null: false
    t.text "note"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["fund_id"], name: "index_recurring_expenses_on_fund_id"
    t.index ["next_run_date"], name: "index_recurring_expenses_on_next_run_date"
    t.index ["user_id", "active"], name: "index_recurring_expenses_on_user_id_and_active"
    t.index ["user_id"], name: "index_recurring_expenses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
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
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["guardian_id"], name: "index_users_on_guardian_id"
    t.index ["guardian_uid"], name: "index_users_on_guardian_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "expenses", "funds"
  add_foreign_key "expenses", "users"
  add_foreign_key "fund_users", "funds"
  add_foreign_key "fund_users", "users"
  add_foreign_key "fund_users", "users", column: "assigned_by_id"
  add_foreign_key "funds", "users", column: "admin_id"
  add_foreign_key "recurring_expenses", "funds"
  add_foreign_key "recurring_expenses", "users"
  add_foreign_key "users", "users", column: "guardian_id"
end
