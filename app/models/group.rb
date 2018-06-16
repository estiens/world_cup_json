class Group < ActiveRecord::Base
  has_many :teams

  def ordered_teams
    @teams = teams.order(:team_points).order(:team_goal_differential)
    @teams = @teams.reverse
  end
end
