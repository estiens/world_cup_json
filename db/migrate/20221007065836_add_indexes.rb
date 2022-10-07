class AddIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :matches, :home_team_id
    add_index :matches, :away_team_id
    add_index :events, :team_id
    add_index :teams, :group_id
    add_index :match_statistics, %i[team_id match_id]
    add_index :teams, :fifa_code
    add_index :matches, :fifa_id
  end
end
