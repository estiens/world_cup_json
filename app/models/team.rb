class Team < ActiveRecord::Base

  has_many :home_matches, :class_name => Match, :foreign_key => "home_team_id"
  has_many :away_matches, :class_name => Match, :foreign_key => "away_team_id"
  has_many :events
  belongs_to :group

  def matches
    Match.where("home_team_id = ? OR away_team_id = ?", self.id, self.id)
  end

  def home_wins
    Match.where("status = ? AND home_team_id = ? AND home_team_score > away_team_score", "completed", self.id).count
  end

  def home_goals_for
    Match.where("status = ? AND home_team_id = ?", "completed", self.id).sum(:home_team_score)
  end

  def away_goals_for
    Match.where("status = ? AND away_team_id = ?", "completed", self.id).sum(:away_team_score)
  end

  def home_goals_against
    Match.where("status = ? AND home_team_id = ?", "completed", self.id).sum(:away_team_score)
  end

  def away_goals_against
    Match.where("status = ? AND away_team_id = ?", "completed", self.id).sum(:home_team_score)
  end

  def away_wins
    Match.where("status = ? AND away_team_id = ? AND home_team_score < away_team_score", "completed", self.id).count
  end


  def home_losses
    Match.where("status = ? AND home_team_id = ? AND home_team_score < away_team_score", "completed", self.id).count
  end

  def away_losses
    Match.where("status = ? AND away_team_id = ? AND home_team_score > away_team_score", "completed", self.id).count
  end

  def team_draws
    self.matches.where("status = ? AND home_team_score == away_team_score", "completed").count
  end

  def team_wins
    self.home_wins + self.away_wins
  end

  def team_losses
    self.home_losses + self.away_losses
  end

  def team_goals_for
    self.home_goals_for + self.away_goals_for
  end

  def team_goals_against
    self.home_goals_against + self.away_goals_against
  end

  def goal_differential
    self.team_goals_for - self.team_goals_against
  end

  def team_points
    self.team_wins * 3 + self.team_draws
  end

  def games_played
    self.team_wins + self.team_losses + self.team_draws
  end
end
