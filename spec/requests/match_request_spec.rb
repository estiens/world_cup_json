require 'rails_helper'

RSpec.describe 'MatchRequest', type: :request do
  let(:json_file) { File.read(Rails.root.join('spec/support/api_match_response.json').to_s) }
  let(:group) { Group.create(letter: 'T') }
  let!(:home_team) { Team.create(country: 'HTA', alternate_name: 'Home Test', group: group) }
  let!(:away_team) { Team.create(country: 'ATS', alternate_name: 'Away Test', group: group) }
  let!(:match) do
    Match.create(fifa_id: '400180541', home_team: home_team, away_team: away_team,
                 fifa_competition_id: '520', fifa_stage_id: '111', fifa_group_id: '222',
                 fifa_season_id: '333', latest_json: JSON.parse(json_file).to_json)
  end

  before(:each) do
    match.update!(status: :in_progress)
    MatchWriter.new(match: match).write_match
    match.save
  end

  it 'should return a full payload for index endpoint (no details)' do
    res = get matches_path
    expect(res).to eq 200

    json = JSON.parse(response.body)
    present_keys = %w[id
                      venue
                      location
                      status
                      attendance
                      officials
                      stage_name
                      home_team_country
                      away_team_country
                      datetime
                      winner
                      winner_code
                      home_team
                      away_team
                      last_checked_at
                      last_changed_at]
    keys_in_response = json.first.map { |k, v| v.present? ? k : nil }.compact
    expect(keys_in_response).to match_array(present_keys)
  end

  it 'should return all details in the match show endpoint' do
    res = get "/matches/#{match.id}"
    expect(res).to eq 200
    # json = JSON.parse(response.body)
  end
end
