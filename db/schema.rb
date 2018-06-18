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

ActiveRecord::Schema.define(version: 20180618003513) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
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

  add_index "events", ["team_id"], name: "index_events_on_team_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "letter",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "match_statistics", force: :cascade do |t|
    t.integer  "team_id",          null: false
    t.integer  "match_id",         null: false
    t.integer  "attempts_on_goal"
    t.integer  "on_target"
    t.integer  "off_target"
    t.integer  "blocked"
    t.integer  "woodwork"
    t.integer  "corners"
    t.integer  "offsides"
    t.integer  "ball_possession"
    t.integer  "pass_accuracy"
    t.integer  "num_passes"
    t.integer  "passes_completed"
    t.integer  "distance_covered"
    t.integer  "balls_recovered"
    t.integer  "tackles"
    t.integer  "clearances"
    t.integer  "yellow_cards"
    t.integer  "red_cards"
    t.integer  "fouls_committed"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "match_statistics", ["match_id"], name: "index_match_statistics_on_match_id", using: :btree
  add_index "match_statistics", ["team_id", "match_id"], name: "index_match_statistics_on_team_id_and_match_id", using: :btree
  add_index "match_statistics", ["team_id"], name: "index_match_statistics_on_team_id", using: :btree

  create_table "matches", force: :cascade do |t|
    t.string   "fifa_id"
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
    t.integer  "home_team_penalties"
    t.integer  "away_team_penalties"
    t.string   "venue"
    t.string   "time"
    t.datetime "last_score_update_at"
    t.datetime "last_event_update_at"
    t.string   "winner_country"
    t.string   "winner_code"
    t.boolean  "stats_complete",       default: false, null: false
    t.integer  "winner_id"
    t.boolean  "draw",                 default: false, null: false
  end

  add_index "matches", ["away_team_id"], name: "index_matches_on_away_team_id", using: :btree
  add_index "matches", ["fifa_id"], name: "index_matches_on_fifa_id", using: :btree
  add_index "matches", ["home_team_id"], name: "index_matches_on_home_team_id", using: :btree
  add_index "matches", ["winner_id"], name: "index_matches_on_winner_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "country"
    t.string   "alternate_name"
    t.string   "fifa_code"
    t.integer  "group_id"
    t.integer  "draws"
    t.boolean  "knocked_out"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "iso_code"
    t.integer  "team_wins"
    t.integer  "team_losses"
    t.integer  "team_draws"
    t.integer  "games_played"
    t.integer  "team_points"
    t.integer  "team_goals_for"
    t.integer  "team_goals_against"
    t.integer  "team_goal_differential"
  end

  add_index "teams", ["fifa_code"], name: "index_teams_on_fifa_code", using: :btree
  add_index "teams", ["group_id"], name: "index_teams_on_group_id", using: :btree

end
