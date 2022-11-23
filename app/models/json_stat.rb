class JsonStat
  attr_reader :home_stats, :away_stats, :possession_stats

  def base_match_number
    132_993
  end

  def base_url(id:, old_code: nil)
    url = 'https://fdh-api.fifa.com/v1/stats/match/'
    number = old_code || base_match_number + id
    "#{url}#{number}/teams.json"
  end

  def initialize(match:)
    @match = match
    @url = base_url(id: @match.id, old_code: @match.old_match_id)
    @modifier = 0
    @json_stats = match_stats_for_home_team
    @home_stats = @json_stats.present? ? @json_stats[@match.home_team.fifa_code] : nil
    @away_stats = @json_stats.present? ? @json_stats[@match.home_team.fifa_code] : nil
    write_the_stats
  end

  private

  def write_the_stats
    write_home_stats if @home_stats
    write_away_stats if @away_stats
  end

  def stats_keys
    [
      { key: 'AttemptAtGoal', stat: 'attempts_on_goal' },
      { key: 'AttemptAtGoalOnTarget', stat: 'on_target' },
      { key: 'AttemptAtGoalOffTarget', stat: 'off_target' },
      { key: 'AttemptAtGoalBlocked', stat: 'blocked' },
      { key: 'Corners', stat: 'corners' },
      { key: 'Offsides', stat: 'offsides' },
      { key: 'Passes', stat: 'num_passes' },
      { key: 'PassesCompleted', stat: 'passes_completed' },
      { key: 'YellowCards', stat: 'yellow_cards' },
      { key: 'RedCards', stat: 'red_cards' },
      { key: 'FoulsFor', stat: 'fouls_committed' },
      { key: 'GoalKicks', stat: 'goal_kicks' },
      { key: 'FreeKicks', stat: 'free_kicks' },
      { key: 'ThrowIns', stat: 'throw_ins' },
      { key: 'Penalties', stat: 'penalties' },
      { key: 'LinebreaksCompletedAllLines', stat: 'tackles' },
      { key: 'PenaltiesScored', stat: 'penalties_scored' },
      { key: 'AttemptAtGoalAgainst', stat: 'attempts_on_goal_against' }
    ]
  end

  def write_home_stats
    write_stats(@home_stats, team: @match.home_team)
  end

  def write_away_stats
    write_stats(@away_stats, team: @match.away_team)
  end

  def write_stats(stats, team:)
    match_stat = MatchStatistic.find_by(match: @match, team: team)
    return unless stats && match_stat

    puts stats.map { |s| s.first }.sort
    stats_keys.each do |hash|
      value_array = stats.find { |a| a.first == hash[:key] }
      value = value_array.is_a?(Array) ? value_array[1].to_i : nil

      match_stat.public_send("#{hash[:stat]}=", value)
    end
    match_stat.save
  end

  def http_request
    uri = URI(@url)
    res = Net::HTTP.get_response(uri)
    return res.body if res.is_a? Net::HTTPOK

    nil
  end

  def response_has_data?(response, home_team: true)
    return false unless response

    if home_team
      response[@match.home_team.fifa_code].present?
    else
      response[@match.away_team.fifa_code].present?
    end
  end

  def find_match_stats_for_home_team(val: 0)
    @url = base_url(id: @match.id + val)
    response = JSON.parse(http_request)
    response_has_data?(response) ? response : false
  rescue StandardError => _e
    false
  end

  def match_stats_for_home_team(val: 1)
    response = find_match_stats_for_home_team
    return response if response.present?

    while val < 4
      response = find_match_stats_for_home_team(val: val) || find_match_stats_for_home_team(val: (0 - val))
      break if response_has_data?(response)

      val += 1
    end
    response
  end
end
