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

ActiveRecord::Schema.define(version: 20140619165809) do

  create_table "events", force: true do |t|
    t.string   "type_of_event"
    t.string   "player"
    t.string   "time"
    t.boolean  "home_team"
    t.integer  "match_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fifa_id"
    t.integer  "team_id"
  end

  create_table "matches", force: true do |t|
    t.string   "fifa_id"
    t.integer  "match_number"
    t.string   "location"
    t.datetime "datetime"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.string   "home_team_tbd"
    t.string   "away_team_tbd"
    t.boolean  "teams_scheduled"
    t.integer  "home_team_score"
    t.integer  "away_team_score"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", force: true do |t|
    t.string   "country"
    t.string   "alternate_name"
    t.string   "fifa_code"
    t.integer  "group_id"
    t.integer  "wins"
    t.integer  "draws"
    t.integer  "losses"
    t.integer  "goals_for"
    t.integer  "goals_against"
    t.boolean  "knocked_out"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
