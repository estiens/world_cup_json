# frozen_string_literal: true

json.array! @matches do |match|
  json.partial! 'matches/match', match: match
end
