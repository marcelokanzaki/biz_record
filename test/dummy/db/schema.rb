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

ActiveRecord::Schema[7.1].define(version: 2026_05_24_000001) do
  create_table "accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "biz_record_days", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "schedule_id", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["schedule_id", "type", "date"], name: "index_biz_record_days_on_schedule_type_and_date", unique: true
  end

  create_table "biz_record_intervals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.time "ends_at", null: false
    t.integer "owner_id", null: false
    t.string "owner_type", null: false
    t.time "starts_at", null: false
    t.datetime "updated_at", null: false
    t.string "weekday"
    t.index ["owner_type", "owner_id", "weekday", "starts_at"], name: "index_biz_record_intervals_on_owner_weekday_and_starts_at", unique: true
  end

  create_table "biz_record_schedules", force: :cascade do |t|
    t.json "configuration", null: false
    t.datetime "created_at", null: false
    t.string "key", default: "default", null: false
    t.integer "schedulable_id", null: false
    t.string "schedulable_type", null: false
    t.string "time_zone", null: false
    t.datetime "updated_at", null: false
    t.index ["schedulable_type", "schedulable_id", "key"], name: "index_biz_record_schedules_on_schedulable_and_key", unique: true
  end
end
