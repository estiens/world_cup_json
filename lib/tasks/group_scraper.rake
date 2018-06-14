require 'open-uri'
# DEPRECATED
BASE_URL = "https://www.fifa.com/worldcup/groups/index.html"
data_class_pairs = { wins: 'fi-table__win', losses: 'fi-table__lost',
                     draws: 'fi-table__draw', goals_for: 'fi-table__goalfor',
                     goals_against: 'fi-table__goalagainst'}

namespace :fifa do
  desc "scrape results from FIFA site"
  task get_group_results: :environment do
    page = Nokogiri::HTML(open(BASE_URL))
    team_code_array = page.css('.t-nTri')

    # traverse the DOM to get back to the parent with all the scores
    def path_to_formatted_data(selector, selection)
      selector.parent.parent.parent.parent.css(selection).text.to_i
    end

    Team.all.each do |team|
      team_code_array.each do |selector|
        next unless selector.text.downcase == team.fifa_code.downcase
        # this may be one level of abstraction too high
        data_class_pairs.each do |attribute, lookup_class|
          data = path_to_formatted_data(selector, lookup_class)
          if data.positive? && (team.send(attribute) != data)
            team.send("#{attribute}=", data)
          end
        end
      end
      team.save
    end
  end
end
