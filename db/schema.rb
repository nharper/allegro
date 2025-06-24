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

ActiveRecord::Schema[7.0].define(version: 2025_06_24_022917) do
  create_table "attendance_records", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "performer_id"
    t.integer "rehearsal_id"
    t.boolean "present"
    t.string "notes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["performer_id"], name: "index_attendance_records_on_performer_id"
    t.index ["rehearsal_id"], name: "index_attendance_records_on_rehearsal_id"
  end

  create_table "cards", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "card_id"
    t.integer "performer_id"
    t.boolean "active"
    t.datetime "expiration_date", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["performer_id"], name: "index_cards_on_performer_id"
  end

  create_table "concerts", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "foreign_key"
    t.boolean "is_active"
  end

  create_table "oauth2_providers", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "auth_url"
    t.string "token_url"
    t.string "id_url"
    t.string "client_id"
    t.string "client_secret"
    t.text "auth_params"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["slug"], name: "index_oauth2_providers_on_slug", unique: true
  end

  create_table "performers", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.binary "photo", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "foreign_key"
    t.string "email"
    t.string "photo_handle"
  end

  create_table "raw_attendance_records", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "performer_id"
    t.integer "rehearsal_id"
    t.integer "kind"
    t.boolean "present"
    t.datetime "timestamp", precision: nil
    t.integer "attendance_record_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["attendance_record_id"], name: "index_raw_attendance_records_on_attendance_record_id"
    t.index ["performer_id"], name: "index_raw_attendance_records_on_performer_id"
    t.index ["rehearsal_id"], name: "index_raw_attendance_records_on_rehearsal_id"
  end

  create_table "registrations", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "section"
    t.string "chorus_number"
    t.string "status"
    t.integer "performer_id"
    t.integer "concert_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["concert_id"], name: "index_registrations_on_concert_id"
    t.index ["performer_id"], name: "index_registrations_on_performer_id"
  end

  create_table "rehearsals", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.datetime "start_date", precision: nil
    t.integer "attendance"
    t.integer "concert_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "name"
    t.string "slug"
    t.datetime "end_date", precision: nil
    t.integer "weight"
    t.integer "start_grace_period"
    t.integer "end_grace_period"
    t.string "foreign_key"
    t.integer "max_missed_time"
    t.string "policy", limit: 16384
    t.index ["concert_id"], name: "index_rehearsals_on_concert_id"
    t.index ["slug"], name: "index_rehearsals_on_slug"
  end

  create_table "scraper_credentials", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "cookie_name"
    t.string "cookie_value", limit: 4096
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_scraper_credentials_on_user_id"
  end

  create_table "user_oauth2_accounts", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "oauth2_provider_id"
    t.string "provider_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "access_token"
    t.text "refresh_token"
    t.index ["oauth2_provider_id"], name: "index_user_oauth2_accounts_on_oauth2_provider_id"
    t.index ["user_id"], name: "index_user_oauth2_accounts_on_user_id"
  end

  create_table "users", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "performer_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "login_token"
    t.string "permissions"
    t.string "subscriptions"
    t.index ["login_token"], name: "index_users_on_login_token"
    t.index ["performer_id"], name: "index_users_on_performer_id"
  end

  add_foreign_key "attendance_records", "performers"
  add_foreign_key "attendance_records", "rehearsals"
  add_foreign_key "cards", "performers"
  add_foreign_key "raw_attendance_records", "attendance_records"
  add_foreign_key "raw_attendance_records", "performers"
  add_foreign_key "raw_attendance_records", "rehearsals"
  add_foreign_key "registrations", "concerts"
  add_foreign_key "registrations", "performers"
  add_foreign_key "scraper_credentials", "users"
  add_foreign_key "user_oauth2_accounts", "oauth2_providers"
  add_foreign_key "user_oauth2_accounts", "users"
  add_foreign_key "users", "performers"
end
