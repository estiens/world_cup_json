require 'open-uri'

BASE_URL = "http://www.fifa.com/worldcup/groups/index.html"
data_class_pairs = {wins:'.tbl-win',losses:'.tbl-lost', draws: '.tbl-draw', goals_for: '.tbl-goalfor', goals_against: 'tbl-goalagainst'}

namespace :fifa do
  desc "scrape results from FIFA site"
  task get_group_results: :environment do
    page = Nokogiri::HTML(open(BASE_URL))
    team_code_array = page.css('.t-nTri') # array of all objects that have this class

    #traverse the DOM to get back to the parent with all the scores
    def path_to_formatted_data(selector, selection)
      selector.parent.parent.parent.parent.css(selection).text.to_i
    end

    Team.all.each do |team|
      team_code_array.each do |selector|
        if (selector.text.downcase == team.fifa_code.downcase)
          data_class_pairs.each do |attribute, lookup_class| # this may be one level of abstraction too high
            data = path_to_formatted_data(selector, lookup_class)
            if (data > 0) && (team.send(attribute) != data)
              team.send("#{attribute}=",data)
            end
          end
        end
      end
      team.save
    end
  end
end






