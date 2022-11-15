class MatchWriter
  attr_accessor :match
  attr_reader :json_match

  # sets up new matches from a blob of json
  def self.setup_match(match_data)
    match_data = match_data.to_json unless match_data.is_a?(String)
    new(json_string: match_data).create_match
  end

  # can be initialized with a match (which has latest json saved on it)
  # or along with the json depending on synch/async updates
  def initialize(match: nil, json_string: nil)
    @match = match
    json_string ||= match.latest_json
    @json_match = JsonMatch.new(json_string)
    @changed = []
  end

  def create_match
    return false if @match&.persisted?

    match = Match.new(match_identifiers)
    match.latest_json = @json_match.to_s
    match.save
  end

  # returns true if the match was updated
  # which requires something to have changed
  # or if in progress
  def write_match
    return false unless @match&.persisted?
    return false unless update_match_from_json

    Rails.logger.info("MatchWriter: #{match.fifa_id} updated - Changed: #{@changed.inspect}")
    match.last_changed_at = Time.zone.now
    match.last_changed = @changed
    match.save
  end

  private

  def complete_match!
    return unless match.status == :in_progress
    return unless @json_match.completed?

    match.update!(status: :completed)
  end

  def write_current_match
    write_score_info
    write_home_stats
    write_away_stats
    write_events
    match.save
    complete_match!
  end

  def write_events
    JsonMatch::EventWriter.new(match: match).write!
  end

  def update_match_in_progress
    return false unless match.status == :in_progress

    write_current_match
    @changed = [:currently_in_progress]
    match.save
  end

  def update_match_from_json
    changed = false
    match.update_column(:last_checked_at, Time.now)
    changed = true if update_match_in_progress
    changed = true if try_update_if_blank?(match_identifiers.merge(team_ids))
    changed = true if try_update_anything?(general_info_attributes)
    changed
  end

  def try_update_if_blank?(attrs)
    updated = false
    attrs.each do |match_stat|
      next if match.public_send(match_stat.first).present?

      updated = true
      @changed << match_stat.first
      match.public_send("#{match_stat.first}=", match_stat.last)
    end
    updated
  end

  def try_update_anything?(attrs)
    updated = false
    attrs.each do |match_stat|
      next if match.public_send(match_stat.first) == match_stat.last

      updated = true
      @changed << match_stat.first
      match.public_send("#{match_stat.first}=", match_stat.last)
    end
    updated
  end

  def match_identifiers
    { fifa_id: @json_match.identifiers[:fifa_id],
      fifa_competition_id: @json_match.identifiers[:competition_id],
      fifa_season_id: @json_match.identifiers[:season_id],
      fifa_group_id: @json_match.identifiers[:group_id],
      fifa_stage_id: @json_match.identifiers[:stage_id],
      stage_name: @json_match.identifiers[:stage_name] }
  end

  def team_ids
    { home_team_id: @json_match.home_team_id,
      away_team_id: @json_match.away_team_id }
  end

  def general_info_attributes
    {
      home_team_tbd: @json_match.placeholder_teams[:home_team],
      away_team_tbd: @json_match.placeholder_teams[:away_team],
      datetime: @json_match.date_info[:date],
      venue: @json_match.location_info[:venue],
      location: @json_match.location_info[:location],
      officials: @json_match.general_info[:officials],
      attendance: @json_match.general_info[:attendance],
      weather: @json_match.general_info[:weather]
    }
  end

  def find_or_create_stats(team)
    MatchStatistic.find_or_create_by(match: match, team: team)
  end

  def write_home_stats
    stats = find_or_create_stats(match.home_team)
    stats.starting_eleven ||= @json_match.home_team_info[:starting_eleven]
    stats.substitutes ||= @json_match.home_team_info[:substitutes]
    stats.tactics ||= @json_match.home_team_info[:tactics]
    return unless stats.changed?

    stats.save
  end

  def write_away_stats
    stats = find_or_create_stats(match.away_team)
    stats.starting_eleven ||= @json_match.away_team_info[:starting_eleven]
    stats.substitutes ||= @json_match.away_team_info[:substitutes]
    stats.tactics ||= @json_match.away_team_info[:tactics]
    return unless stats.changed?

    stats.save
  end

  def write_score_info
    match.home_team_score = @json_match.score_info[:home_score]
    match.away_team_score = @json_match.score_info[:away_score]
    match.away_team_penalties = @json_match.score_info[:away_penalties]
    match.home_team_penalties = @json_match.score_info[:home_penalties]
  end
end
