class Team < ActiveRecord::Base

  has_many :home_matches, :class_name => Match, :foreign_key => "home_team_id" do
    def completed
      where("status = ?", 'completed')
    end
    def wins
      where("status = ? AND home_team_score > away_team_score OR home_team_penalties > away_team_penalties", "completed")
    end
    def losses
      where("status = ? AND home_team_score < away_team_score OR home_team_penalties < away_team_penalties", "completed")
    end
  end

  has_many :away_matches, :class_name => Match, :foreign_key => "away_team_id" do
    def completed
      where("status = ?", 'completed')
    end
    def wins
      where("status = ? AND home_team_score < away_team_score OR home_team_penalties < away_team_penalties", "completed")
    end
    def losses
      where("status = ? AND home_team_score > away_team_score OR home_team_penalties > away_team_penalties", "completed")
    end
  end

  has_many :events
  belongs_to :group


  def matches
    Match.where("home_team_id = ? OR away_team_id = ?", self.id, self.id)
  end

  def home_wins
    self.home_matches.wins.count
  end

  def home_goals_for
    self.home_matches.completed.sum(:home_team_score)
  end

  def away_goals_for
    self.away_matches.completed.sum(:away_team_score)
  end

  def home_goals_against
    self.home_matches.completed.sum(:away_team_score)
  end

  def away_goals_against
    self.away_matches.completed.sum(:home_team_score)
  end

  def away_wins
    self.away_matches.wins.count
  end


  def home_losses
    self.home_matches.losses.count
  end

  def away_losses
    self.away_matches.losses.count
  end

  def team_draws
    self.matches.where("status = ? AND home_team_score = away_team_score AND home_team_penalties IS NULL", "completed").count
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
