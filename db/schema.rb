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

ActiveRecord::Schema.define(version: 20130415120854) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appearances", force: true do |t|
    t.integer "greeting_id",        null: false
    t.integer "character_id",       null: false
    t.integer "costume_id"
    t.string  "raw_character_name", null: false
  end

  add_index "appearances", ["character_id", "costume_id"], name: "index_appearances_on_character_id_and_costume_id", using: :btree
  add_index "appearances", ["character_id"], name: "index_appearances_on_character_id", using: :btree
  add_index "appearances", ["greeting_id", "character_id", "costume_id"], name: "index_appearances_uniqueness", unique: true, using: :btree
  add_index "appearances", ["greeting_id"], name: "index_appearances_on_greeting_id", using: :btree

  create_table "characters", force: true do |t|
    t.string "name", null: false
  end

  add_index "characters", ["name"], name: "index_characters_on_name", using: :btree

  create_table "costumes", force: true do |t|
    t.string "name", null: false
  end

  add_index "costumes", ["name"], name: "index_costumes_on_name", using: :btree

  create_table "greetings", force: true do |t|
    t.datetime "start_at",       null: false
    t.datetime "end_at",         null: false
    t.integer  "place_id",       null: false
    t.integer  "schedule_id",    null: false
    t.string   "raw_place_name", null: false
    t.boolean  "deleted",        null: false
  end

  add_index "greetings", ["id"], name: "index_greetings_on_id", where: "(NOT deleted)", using: :btree
  add_index "greetings", ["place_id"], name: "index_greetings_place_id_deleted", where: "deleted", using: :btree
  add_index "greetings", ["place_id"], name: "index_greetings_place_id_not_deleted", where: "(NOT deleted)", using: :btree
  add_index "greetings", ["schedule_id"], name: "index_greetings_on_schedule_id", where: "(NOT deleted)", using: :btree
  add_index "greetings", ["start_at", "end_at", "place_id", "schedule_id", "deleted"], name: "index_greetings_uniqueness", unique: true, using: :btree
  add_index "greetings", ["start_at", "end_at"], name: "index_greetings_time_deleted", where: "deleted", using: :btree
  add_index "greetings", ["start_at", "end_at"], name: "index_greetings_time_not_deleted", where: "(NOT deleted)", using: :btree
  add_index "greetings", ["start_at"], name: "index_greetings_on_start_at", using: :btree

  create_table "places", force: true do |t|
    t.string "name", null: false
  end

  create_table "schedules", force: true do |t|
    t.date "date", null: false
  end

  add_index "schedules", ["date"], name: "index_schedules_on_date", using: :btree

end
