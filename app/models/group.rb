class Group < ActiveRecord::Base
  has_many :teams

  def ordered_teams
    @teams = teams.order(:team_points).order(:team_goal_differential).order(:team_goals_for)
    @teams = @teams.reverse
  end
end
