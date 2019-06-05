# frozen_string_literal: true

class MatchStatistic < ActiveRecord::Base
  belongs_to :team
  belongs_to :match
end
