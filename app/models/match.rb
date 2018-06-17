class Match < ActiveRecord::Base
  validates_presence_of :home_team, :away_team, :datetime, :status

  belongs_to :home_team, class_name: Team, foreign_key: 'home_team_id'
  belongs_to :away_team, class_name: Team, foreign_key: 'away_team_id'
  has_many :events
  has_many :match_statistics

  after_save :update_teams

  def self.by_date(start_time, end_time = nil)
    start_time = Time.parse(start_time) unless start_time.is_a? Time
    if end_time
      end_time = Time.parse(end_time) unless start_time.is_a? Time
    else
      end_time = start_time
    end
    start_filter = start_time.beginning_of_day
    end_filter = end_time.end_of_day
    where(datetime: start_filter..end_filter).order(:datetime)
  end

  def self.today
    by_date(Time.now)
  end

  def self.tomorrow
    by_date(Time.now.advance(days: 1))
  end

  def self.completed
    where(status: 'completed')
  end

  def scrape_stats
    puts 'Match still in future, no stats' && return if status == 'future'
    scraper = Scrapers::FactScraper.new(match: self)
    begin
      scraper.scrape
    rescue 
      puts "Stats scraper failure for #{name}"
    end
  end

  def name
    home_team_desc = home_team&.country || home_team_tbd
    away_team_desc = away_team&.country || away_team_tbd
    "#{home_team_desc} vs #{away_team_desc}"
  end

  def home_team_events
    events.where(team: home_team)
  end

  def away_team_events
    events.where(team: away_team)
  end

  def home_stats
    match_statistics.where(team: home_team).first
  end

  def away_stats
    match_statistics.where(team: away_team).first
  end

  private

  def update_teams
    home_team.save && away_team.save
  end
end
