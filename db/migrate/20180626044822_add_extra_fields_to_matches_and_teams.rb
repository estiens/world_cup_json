class AddExtraFieldsToMatchesAndTeams < ActiveRecord::Migration
  def change
    add_column :matches, :weather, :json
    add_column :matches, :attendance, :string
    add_column :matches, :json_home_team_score, :integer
    add_column :matches, :json_away_team_score, :integer
    add_column :matches, :json_home_team_penalties, :integer
    add_column :matches, :json_away_team_penalties, :integer
    add_column :matches, :officials, :json
    add_column :match_statistics, :starting_eleven, :json
    add_column :match_statistics, :substitutes, :json
    add_column :match_statistics, :tactics, :string
  end
end
