class Group < ActiveRecord::Base
  has_many :teams

  def ordered_teams
    self.teams.sort_by!{|team| [team.team_points, team.goal_differential]}.reverse
  end
end
