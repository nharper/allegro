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

ActiveRecord::Schema.define(version: 20150718051413) do

  create_table "attendance_records", force: :cascade do |t|
    t.integer  "performer_id"
    t.integer  "rehearsal_id"
    t.boolean  "present"
    t.integer  "type"
    t.string   "notes"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "attendance_records", ["performer_id"], name: "index_attendance_records_on_performer_id"
  add_index "attendance_records", ["rehearsal_id"], name: "index_attendance_records_on_rehearsal_id"

  create_table "concerts", force: :cascade do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth2_providers", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "auth_url"
    t.string   "token_url"
    t.string   "id_url"
    t.string   "client_id"
    t.string   "client_secret"
    t.text     "auth_params"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "oauth2_providers", ["slug"], name: "index_oauth2_providers_on_slug", unique: true

  create_table "performers", force: :cascade do |t|
    t.string   "name"
    t.binary   "photo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registrations", force: :cascade do |t|
    t.string   "section"
    t.string   "chorus_number"
    t.string   "status"
    t.integer  "performer_id"
    t.integer  "concert_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "registrations", ["concert_id"], name: "index_registrations_on_concert_id"
  add_index "registrations", ["performer_id"], name: "index_registrations_on_performer_id"

  create_table "rehearsals", force: :cascade do |t|
    t.datetime "date"
    t.integer  "attendance"
    t.integer  "concert_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rehearsals", ["concert_id"], name: "index_rehearsals_on_concert_id"

end
