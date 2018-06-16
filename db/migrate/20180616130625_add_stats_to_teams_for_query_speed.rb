class AddStatsToTeamsForQuerySpeed < ActiveRecord::Migration
  def change
    remove_column :teams, :wins, :integer
    remove_column :teams, :losses, :integer
    remove_column :teams, :goals_for, :integer
    remove_column :teams, :goals_against, :integer
    add_column :teams, :team_wins, :integer
    add_column :teams, :team_losses, :integer
    add_column :teams, :team_draws, :integer
    add_column :teams, :games_played, :integer
    add_column :teams, :team_points, :integer
    add_column :teams, :team_goals_for, :integer
    add_column :teams, :team_goals_against, :integer
    add_column :teams, :team_goal_differential, :integer
  end
end
