require 'rails_helper'

RSpec.describe JsonMatch, :type => :model do
  let(:json_file) { File.read(Rails.root.join('spec/support/api_match_response.json').to_s) }
  let(:group) { Group.create(letter: 'T') }
  let!(:home_team) { Team.create(country: 'HTA', alternate_name: 'Home Test', group: group) }
  let!(:away_team) { Team.create(country: 'ATS', alternate_name: 'Away Test', group: group) }
  let!(:match) do
    Match.create(fifa_id: '400180541', home_team: home_team, away_team: away_team,
                 fifa_competition_id: '520', latest_json: JSON.parse(json_file).to_json)
  end
  let(:json_match) { JsonMatch.new(match.reload.latest_json) }

  before(:each) do
    expect(json_match.info).to be_a(Hash)
  end

  it 'should return basic info about the match' do
    expected_info = { :fifa_id => '400180541', :season_id => '282653', :stage_id => '282667', :group_id => '284947',
                      :competition_id => '520', :stage_name => 'Final Round' }
    expect(json_match.identifiers.sort).to match_array(expected_info.sort)
  end

  it 'should return info about the location of the match' do
    officials_array = [{ :name => 'F. Hernández', :role => 'Referee', :country => 'MEX' },
                       { :name => 'Alberto MORIN',
                         :role => 'Assistant Referee 1',
                         :country => 'MEX' },
                       { :name => 'Miguel HERNANDEZ',
                         :role => 'Assistant Referee 2',
                         :country => 'MEX' },
                       { :name => 'D. Montaño', :role => 'Fourth official', :country => 'MEX' }]
    expected_gen_info = { :attendance => '31000', :weather => {}, :officials => officials_array }
    expected_loc_info = { :venue => 'Estadio Olimpico Metropolitano', :location => 'San Pedro Sula' }

    expect(json_match.general_info.sort).to match_array(expected_gen_info.sort)
    expect(json_match.location_info.sort).to match_array(expected_loc_info.sort)
  end

  it 'should return info about each team' do
    expect(json_match.home_team_info.keys).to match_array(%i[tactics starting_eleven substitutes coaches])
    expect(json_match.away_team_info.keys).to match_array(%i[tactics starting_eleven substitutes coaches])
  end

  it 'should have time info' do
    date_info = { :date => '2021-09-09T02:30:00Z', :local_date => '2021-09-08T20:30:00Z' }
    time_info = { :current_time => "0'", :first_half_time => nil, :first_half_extra_time => 3, :second_half_time => nil,
                  :second_half_extra_time => 4 }

    expect(json_match.date_info.sort).to match_array(date_info.sort)
    expect(json_match.current_time_info.sort).to match_array(time_info.sort)
  end
end
