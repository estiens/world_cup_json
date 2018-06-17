class MatchStatistic < ActiveRecord::Base
  belongs_to :team
  belongs_to :match
end
