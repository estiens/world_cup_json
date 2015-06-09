require 'open-uri'
require 'json'

namespace :team do
  task get_all_country_codes: :environment do
    API_ENDPOINT = "http://restcountries.eu/rest/v1/name"
    Team.all.each do |team|
      country = team.country
      country = 'Great%20Britain' if country == "England"
      country = 'South%20Korea' if country == "Korea Republic"
      puts API_ENDPOINT+'/'+country
      json = JSON.parse(open(API_ENDPOINT+"/"+country.gsub(' ', '%20')).read)[0]
      team.country_code = json['alpha2Code']
      team.save
    end
  end
end