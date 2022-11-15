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

  describe 'EventWriter' do
    let(:writer) { JsonMatch::EventWriter.new(match: match) }

    it 'should create events from match json' do
      expect { writer.write! }.to change { Event.count }.by(11)
    end

    it 'should not create events if it is a duplicate' do
      expect(Event.count).to eq 0
      writer.write!
      expect(Event.count).to eq 11
      writer.write!
      expect(Event.count).to eq 11
    end

    it 'should create the proper events' do
      writer.write!

      expect(match.home_team_events.count).to eq(4)
      expect(match.away_team_events.count).to eq(7)

      home_goal = match.home_team_events.find_by(type_of_event: 'goal')
      expect(home_goal.player).to be_present
      expect(home_goal.time).to eq '26:49'

      away_sub = match.away_team_events.find_by(type_of_event: 'substitution')
      expect(away_sub.to_s.strip).to be_present
      expect(away_sub.time).to eq '45:00'
    end
  end
end
