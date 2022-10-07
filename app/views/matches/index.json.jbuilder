# frozen_string_literal: true

json.array! @matches do |match|
  json.cache! ['v2', match], expires_in: 10.minutes do
    json.partial! 'matches/match', match: match
  end
end
