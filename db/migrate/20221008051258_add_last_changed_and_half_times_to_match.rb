class AddLastChangedAndHalfTimesToMatch < ActiveRecord::Migration[7.0]
  def change
    remove_column :matches, :last_score_update_at, :datetime
    remove_column :matches, :last_event_update_at, :datetime
    remove_column :matches, :json_home_team_score, :integer
    remove_column :matches, :json_away_team_score, :integer
    remove_column :matches, :json_home_team_penalties, :integer
    remove_column :matches, :json_away_team_penalties, :integer

    add_column :matches, :last_changed_at, :datetime
    add_column :matches, :last_checked_at, :datetime
    add_column :matches, :detailed_time, :json
    add_column :matches, :last_changed, :json, default: []
  end
end
