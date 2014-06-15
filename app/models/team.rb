class Team < ActiveRecord::Base

  has_many :home_matches, :class_name => Match, :foreign_key => "home_team_id"
  has_many :away_matches, :class_name => Match, :foreign_key => "away_team_id"

  def matches
    Match.where("home_team_id = ? OR away_team_id = ?", self.id, self.id)
  end

end
