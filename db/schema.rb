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

ActiveRecord::Schema[7.1].define(version: 2025_08_13_091500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "check_ins", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "gym_location_id", null: false
    t.datetime "check_in_timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gym_location_id"], name: "index_check_ins_on_gym_location_id"
    t.index ["user_id"], name: "index_check_ins_on_user_id"
  end

  create_table "gym_locations", force: :cascade do |t|
    t.string "qr_code_identifier"
    t.string "branch"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.date "purchase_date"
    t.string "membership_type"
    t.string "status", default: "inactive"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "role", default: 0, null: false
    t.text "content", null: false
    t.jsonb "metadata", default: {}
    t.bigint "workout_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_messages_on_user_id"
    t.index ["workout_plan_id"], name: "index_messages_on_workout_plan_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "amount"
    t.string "transaction_id"
    t.string "status"
    t.string "membership_duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "plan_exercises", force: :cascade do |t|
    t.bigint "workout_plan_id", null: false
    t.string "exercise", null: false
    t.integer "sets"
    t.string "reps"
    t.integer "rest_seconds"
    t.string "tempo"
    t.jsonb "modifiers", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workout_plan_id"], name: "index_plan_exercises_on_workout_plan_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "full_name"
    t.string "phone"
    t.text "address"
    t.date "birthdate"
    t.text "gender"
    t.integer "height_cm"
    t.decimal "weight_kg", precision: 5, scale: 2
    t.integer "ai_weekly_uses_count", default: 0, null: false
    t.date "ai_weekly_period_start"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workout_plans", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "summary"
    t.jsonb "notes", default: {}
    t.string "focus_area"
    t.jsonb "meta", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_workout_plans_on_slug"
    t.index ["user_id"], name: "index_workout_plans_on_user_id"
  end

  add_foreign_key "check_ins", "gym_locations"
  add_foreign_key "check_ins", "users"
  add_foreign_key "memberships", "users"
  add_foreign_key "messages", "users"
  add_foreign_key "messages", "workout_plans"
  add_foreign_key "payments", "users"
  add_foreign_key "plan_exercises", "workout_plans"
  add_foreign_key "workout_plans", "users"
end
