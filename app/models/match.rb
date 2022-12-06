class Match < ActiveRecord::Base
  belongs_to :home_team, class_name: 'Team', foreign_key: 'home_team_id', optional: true
  belongs_to :away_team, class_name: 'Team', foreign_key: 'away_team_id', optional: true
  belongs_to :winner, class_name: 'Team', foreign_key: 'winner_id', optional: true

  has_many :events
  has_many :match_statistics

  before_validation :set_default_status
  before_save :update_status

  after_save :notify_slack
  after_save :update_teams

  STATUSES = %i[incomplete future_unscheduled future_scheduled in_progress completed].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :fifa_competition_id, presence: true

  validate :validate_basic_info, unless: proc { |m| m.status == :incomplete }

  default_scope { includes(:home_team, :away_team, :winner) }

  def self.for_date(start_time, end_time = nil)
    parse_times(start_time, end_time)
    return Match.none unless @start_time && @end_time

    where(datetime: @start_time..@end_time)
  end

  def self.parse_times(start_time, end_time)
    start_time = Chronic.parse(start_time.to_s)
    end_time = Chronic.parse(end_time.to_s)
    end_time ||= start_time
    return unless start_time && end_time

    @start_time = start_time.beginning_of_day
    @end_time = end_time.end_of_day
  end

  def self.next
    today.future.reorder(datetime: :asc).first
  end

  def self.recently_completed
    today.completed.reorder(datetime: :desc).first
  end

  def self.yesterday
    for_date(Time.now - 1.day)
  end

  def self.today
    for_date(Time.now)
  end

  def self.tomorrow
    for_date(Time.now.advance(days: 1))
  end

  def self.completed
    where(status: :completed)
  end

  def self.not_completed
    where.not(status: :completed)
  end

  def self.in_progress
    where(status: :in_progress)
  end

  def self.scheduled_now
    today.future.where('datetime < ?', Time.now)
  end

  def self.future
    where(status: :future_scheduled).or(where(status: :future_unscheduled))
  end

  # check if we even call this
  def self.not_future
    where.not(status: 'future')
  end

  def status
    read_attribute(:status)&.to_sym || :incomplete
  end

  def complete?
    return true if status == :completed

    false
  end
  alias completed? complete?

  def incomplete?
    return true if status.nil?
    return true if status == :incomplete

    false
  end

  def teams_assigned?
    home_team && away_team
  end

  def name
    home_team_desc = home_team&.country || home_team_tbd
    away_team_desc = away_team&.country || away_team_tbd
    "#{home_team_desc} vs #{away_team_desc}"
  end

  def home_team_events
    return [] unless home_team

    @home_team_events ||= events.where(team: home_team).sort_by { |e| e.time.to_i }
  end

  def away_team_events
    return [] unless away_team

    @away_team_events ||= events.where(team: away_team).sort_by { |e| e.time.to_i }
  end

  def home_stats
    @home_stats ||= match_statistics.where(team: home_team).first
  end

  def away_stats
    @away_stats ||= match_statistics.where(team: away_team).first
  end

  def update_self_from_latest_data
    return unless Match.today.include?(self)

    FetchDataForScheduledMatch.perform_later(id)
  end

  private

  def validate_basic_info
    return if fifa_competition_id && fifa_season_id && fifa_stage_id

    errors.add(:base, 'Match is missing basic information')
  end

  def validate_teams_exist
    return if %i[incomplete future_unscheduled].include? status
    return if home_team_id && away_team_id

    errors.add(:base, 'Cannot schedule game without teams')
  end

  def penalty_winner
    return nil unless status == :completed
    return nil unless away_team_penalties.to_i.positive? && home_team_penalties.positive?
    return home_team if home_team_penalties > away_team_penalties
    return away_team if away_team_penalties > home_team_penalties

    nil
  end

  def regulation_winner
    return nil unless status == :completed
    return nil unless home_team_score && away_team_score
    return home_team if home_team_score.to_i > away_team_score.to_i
    return away_team if away_team_score.to_i > home_team_score.to_i

    nil
  end

  def draw?
    return nil unless status == :completed
    return false unless stage_name&.downcase&.include?('first stage')

    home_team_score == away_team_score
  end

  def set_default_status
    self.status ||= :incomplete
  end

  def update_status
    identify! if status == :incomplete
    schedule! if status == :future_unscheduled
    update_self_from_latest_data if status == :future_scheduled
    # determine match is live! if future_scheduled
    # determine completed if in_progress
    determine_winner! if status == :completed
  end

  def schedule!
    return nil unless status == :future_unscheduled

    schedule_info = home_team_id && away_team_id && datetime
    return nil unless schedule_info

    self.status = :future_scheduled
  end

  def identify!
    return nil unless status == :incomplete

    # need these for URL and all matches should have
    complete_info = (fifa_id && fifa_stage_id)
    return nil unless complete_info

    self.status = :future_unscheduled
  end

  def determine_winner!
    # check winner against json?
    return unless status == :completed

    self.winner = penalty_winner
    self.winner ||= regulation_winner
    self.draw = draw?
  end

  def completed_message
    message = "Game complete: Final Score: #{home_team.alternate_name} #{home_team_score}"
    message += " - #{away_team_score} #{away_team.alternate_name}"
    message
  end

  def slack_status_message
    return unless saved_change_to_status.is_a? Array

    case saved_change_to_status.last&.to_sym
    when :completed
      completed_message
    when :in_progress
      game_start_message + home_starters_message + away_starters_message
    end
  end

  def game_start_message
    message = "Kickoff in #{location} #{home_team.alternate_name} vs #{away_team.alternate_name}"
    message += "\n#{weather.inspect}\nAttendance: #{attendance}\n"
    message
  end

  def away_starters_message
    return nil unless away_stats

    message = "\n#{away_team.alternate_name} Starting XI\n"
    message += away_stats.starting_eleven.map do |p|
      "#{p['name']} -- #{p['position']}"
    end.join("\n")
    message
  end

  def home_starters_message
    return nil unless home_stats

    message = "#{home_team.alternate_name} Starting XI\n"
    message += home_stats.starting_eleven.map do |p|
      "#{p['name']} -- #{p['position']}"
    end.join("\n")
    message += "\n--\n"
    message
  end

  def score_message
    "#{home_team.alternate_name}: #{home_team_score} -- #{away_team_score} #{away_team.alternate_name}"
  end

  def penalty_message
    "Penalties: #{home_team.country} #{home_team_penalties} -- #{away_team_penalties} #{away_team.country}"
  end

  def slack_message
    return slack_status_message if status_changed?
    return score_message if saved_change_to_home_team_score? || saved_change_to_away_team_score?
    return penalty_message if saved_change_to_home_team_penalties? || saved_change_to_away_team_penalties?

    nil
  end

  def notify_slack
    return unless ENV.fetch('SLACK_URL', false)
    return unless slack_message

    SlackMessageService.new(message: slack_message).notify
  rescue StandardError => e
    Rails.logger.warn "Error notifying slack: #{e.message}"
  end

  def update_teams
    return unless status == :completed
    return unless winner_id

    home_team.reload.save && away_team.reload.save
  end
end
