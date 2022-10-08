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

ActiveRecord::Schema[7.0].define(version: 2022_10_08_051258) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "type_of_event"
    t.string "player"
    t.string "time"
    t.boolean "home_team"
    t.integer "match_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "fifa_id"
    t.integer "team_id"
    t.index ["team_id"], name: "index_events_on_team_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "letter", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "match_statistics", id: :serial, force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "match_id", null: false
    t.integer "attempts_on_goal"
    t.integer "on_target"
    t.integer "off_target"
    t.integer "blocked"
    t.integer "woodwork"
    t.integer "corners"
    t.integer "offsides"
    t.integer "ball_possession"
    t.integer "pass_accuracy"
    t.integer "num_passes"
    t.integer "passes_completed"
    t.integer "distance_covered"
    t.integer "balls_recovered"
    t.integer "tackles"
    t.integer "clearances"
    t.integer "yellow_cards"
    t.integer "red_cards"
    t.integer "fouls_committed"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.json "starting_eleven"
    t.json "substitutes"
    t.string "tactics"
    t.index ["match_id"], name: "index_match_statistics_on_match_id"
    t.index ["team_id", "match_id"], name: "index_match_statistics_on_team_id_and_match_id"
    t.index ["team_id"], name: "index_match_statistics_on_team_id"
  end

  create_table "matches", id: :serial, force: :cascade do |t|
    t.string "fifa_id"
    t.string "location"
    t.datetime "datetime", precision: nil
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.string "home_team_tbd"
    t.string "away_team_tbd"
    t.boolean "teams_scheduled"
    t.integer "home_team_score"
    t.integer "away_team_score"
    t.string "status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "home_team_penalties"
    t.integer "away_team_penalties"
    t.string "venue"
    t.string "time"
    t.boolean "stats_complete", default: false, null: false
    t.integer "winner_id"
    t.boolean "draw", default: false, null: false
    t.boolean "events_complete", default: false, null: false
    t.string "fifa_competition_id"
    t.string "fifa_season_id"
    t.string "fifa_group_id"
    t.string "fifa_stage_id"
    t.string "stage_name"
    t.json "weather"
    t.string "attendance"
    t.json "officials"
    t.text "latest_json"
    t.datetime "last_changed_at"
    t.datetime "last_checked_at"
    t.json "detailed_time"
    t.json "last_changed", default: []
    t.index ["away_team_id"], name: "index_matches_on_away_team_id"
    t.index ["fifa_id"], name: "index_matches_on_fifa_id"
    t.index ["home_team_id"], name: "index_matches_on_home_team_id"
    t.index ["winner_id"], name: "index_matches_on_winner_id"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string "country"
    t.string "alternate_name"
    t.string "fifa_code"
    t.integer "group_id"
    t.integer "draws"
    t.boolean "knocked_out"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "iso_code"
    t.integer "team_wins"
    t.integer "team_losses"
    t.integer "team_draws"
    t.integer "games_played"
    t.integer "team_points"
    t.integer "team_goals_for"
    t.integer "team_goals_against"
    t.integer "team_goal_differential"
    t.string "flag_url"
    t.index ["fifa_code"], name: "index_teams_on_fifa_code"
    t.index ["group_id"], name: "index_teams_on_group_id"
  end

end
