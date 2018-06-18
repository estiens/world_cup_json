task get_all_matches: :environment do
  def parse_match(match)
    fifa_id = match.first[1] # get unique fifa_id
    fixture = Match.find_or_create_by(fifa_id: fifa_id)
    return nil if fixture.status == 'completed'

    datetime = match.css('.fi-mu__info__datetime')&.text&.strip
    datetime = datetime&.downcase&.gsub('local time', '')&.strip&.to_time

    venue = match.css('.fi__info__venue')&.text

    # comment next line out for set up and scraping of all matches
    # reduces overhead on heroku to only scrape today's matches

    return nil unless datetime&.beginning_of_day&.to_i == Time.now.beginning_of_day.to_i

    location = match.css(".fi__info__stadium")&.text

    home_team_code = match.css(".home .fi-t__nTri")&.text
    away_team_code = match.css(".away .fi-t__nTri")&.text

    # if match is scheduled, associate it with a team, else use tbd variables
    if Team.where(fifa_code: home_team_code).first
      home_team_id = Team.where(fifa_code: home_team_code).first.id
    else
      home_team_tbd = home_team_code
    end
    if Team.where(fifa_code: away_team_code).first
      away_team_id = Team.where(fifa_code: away_team_code).first.id
    else
      away_team_tbd = away_team_code
    end

    fixture.home_team_score ||= 0
    fixture.away_team_score ||= 0
    # FIFA uses the score class to show the time if the match is in the future
    # We don't want that
    if match.css('.fi-s__scoreText')&.text&.include?("-")
      score_array = match.css('.fi-s__scoreText').text.split("-")
      new_ht_score = score_array.first.to_i
      new_at_score = score_array.last.to_i
      fixture.home_team_score = new_ht_score if new_ht_score > fixture.home_team_score
      fixture.away_team_score = new_at_score if new_at_score > fixture.away_team_score
    end
    # this is handled by JS hide/show now will have to figure out how to handle
    penalties = match.css(".fi-mu__reasonwin-text").xpath("//wherever/*[not (@class='hidden')]")
    if penalties.text.downcase.include?("win on penalties")
      # not sure is right in 2018
      penalty_array = penalties.text.split("-")
      home_team_penalties = penalty_array[0].gsub(/[^\d]/, "").to_i
      away_team_penalties = penalty_array[1].gsub(/[^\d]/, "").to_i
    end
    fixture.venue ||= venue
    fixture.location ||= location
    fixture.datetime ||= datetime
    fixture.home_team_id = home_team_id
    fixture.away_team_id = away_team_id
    fixture.home_team_tbd = home_team_tbd
    fixture.away_team_tbd = away_team_tbd
    if home_team_penalties && away_team_penalties
      fixture.home_team_penalties = home_team_penalties
      fixture.away_team_penalties = away_team_penalties
    end

    if match.attributes['class'].value.include?('live')
      fixture.status = 'in progress'
    elsif match.css('.period').css(":not(.hidden)").text.downcase.include?('full-time')
      fixture.status = 'end of time'
    else
      fixture.status ||= 'future'
    end
    fixture.last_score_update_at = Time.now
    @counter += 1 if fixture.save
  end

  matches = get_page_from_url(MATCH_URL)
  @counter = 0
  @live_counter = 0

  matches.css(".fixture").each do |match|
    parse_match(match)
  end

  matches.css(".live").each do |match|
    parse_match(match)
    @live_counter += 1
  end
