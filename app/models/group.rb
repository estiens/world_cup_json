class Group < ActiveRecord::Base
  has_many :teams

  def ordered_teams
    teams.order(:team_points).order(:team_goal_differential)
  end
end
