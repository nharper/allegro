# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170116081445) do

  create_table "attendance_records", force: :cascade do |t|
    t.integer  "performer_id", limit: 4
    t.integer  "rehearsal_id", limit: 4
    t.boolean  "present"
    t.string   "notes",        limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "attendance_records", ["performer_id"], name: "index_attendance_records_on_performer_id", using: :btree
  add_index "attendance_records", ["rehearsal_id"], name: "index_attendance_records_on_rehearsal_id", using: :btree

  create_table "cards", force: :cascade do |t|
    t.string   "card_id",         limit: 255
    t.integer  "performer_id",    limit: 4
    t.boolean  "active"
    t.datetime "expiration_date"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "cards", ["performer_id"], name: "index_cards_on_performer_id", using: :btree

  create_table "concerts", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "foreign_key", limit: 255
  end

  create_table "oauth2_providers", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "slug",          limit: 255
    t.string   "auth_url",      limit: 255
    t.string   "token_url",     limit: 255
    t.string   "id_url",        limit: 255
    t.string   "client_id",     limit: 255
    t.string   "client_secret", limit: 255
    t.text     "auth_params",   limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "oauth2_providers", ["slug"], name: "index_oauth2_providers_on_slug", unique: true, using: :btree

  create_table "performers", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.binary   "photo",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "foreign_key", limit: 255
  end

  create_table "raw_attendance_records", force: :cascade do |t|
    t.integer  "performer_id",         limit: 4
    t.integer  "rehearsal_id",         limit: 4
    t.integer  "kind",                 limit: 4
    t.boolean  "present"
    t.datetime "timestamp"
    t.integer  "attendance_record_id", limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "raw_attendance_records", ["attendance_record_id"], name: "index_raw_attendance_records_on_attendance_record_id", using: :btree
  add_index "raw_attendance_records", ["performer_id"], name: "index_raw_attendance_records_on_performer_id", using: :btree
  add_index "raw_attendance_records", ["rehearsal_id"], name: "index_raw_attendance_records_on_rehearsal_id", using: :btree

  create_table "registrations", force: :cascade do |t|
    t.string   "section",       limit: 255
    t.string   "chorus_number", limit: 255
    t.string   "status",        limit: 255
    t.integer  "performer_id",  limit: 4
    t.integer  "concert_id",    limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "registrations", ["concert_id"], name: "index_registrations_on_concert_id", using: :btree
  add_index "registrations", ["performer_id"], name: "index_registrations_on_performer_id", using: :btree

  create_table "rehearsals", force: :cascade do |t|
    t.datetime "start_date"
    t.integer  "attendance",         limit: 4
    t.integer  "concert_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",               limit: 255
    t.string   "slug",               limit: 255
    t.datetime "end_date"
    t.integer  "weight",             limit: 4
    t.integer  "start_grace_period", limit: 4
    t.integer  "end_grace_period",   limit: 4
    t.string   "foreign_key",        limit: 255
  end

  add_index "rehearsals", ["concert_id"], name: "index_rehearsals_on_concert_id", using: :btree
  add_index "rehearsals", ["slug"], name: "index_rehearsals_on_slug", using: :btree

  create_table "scraper_credentials", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.string   "cookie_name",  limit: 255
    t.string   "cookie_value", limit: 4096
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "scraper_credentials", ["user_id"], name: "index_scraper_credentials_on_user_id", using: :btree

  create_table "user_oauth2_accounts", force: :cascade do |t|
    t.integer  "oauth2_provider_id", limit: 4
    t.string   "provider_id",        limit: 255
    t.integer  "user_id",            limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "user_oauth2_accounts", ["oauth2_provider_id"], name: "index_user_oauth2_accounts_on_oauth2_provider_id", using: :btree
  add_index "user_oauth2_accounts", ["user_id"], name: "index_user_oauth2_accounts_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.integer  "performer_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "login_token",  limit: 255
  end

  add_index "users", ["login_token"], name: "index_users_on_login_token", using: :btree
  add_index "users", ["performer_id"], name: "index_users_on_performer_id", using: :btree

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
