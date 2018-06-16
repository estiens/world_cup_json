class Match < ActiveRecord::Base
  validates_presence_of :home_team, :away_team, :datetime, :status

  belongs_to :home_team, :class_name => Team, :foreign_key => "home_team_id"
  belongs_to :away_team, :class_name => Team, :foreign_key => "away_team_id"
  has_many :events

  after_save :update_teams

  def self.today
    where(datetime: Time.now.beginning_of_day..Time.now.end_of_day).order(:datetime)
  end

  def self.tomorrow
    where(datetime: Time.now.advance(days: 1).beginning_of_day..Time.now.advance(days: 1).end_of_day).order(:datetime)
  end

  private

  def update_teams
    home_team.save && away_team.save
  end
end
