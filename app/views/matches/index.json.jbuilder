# frozen_string_literal: true

json.cache_collection! @matches, expires_in: @cache_time do |match|
  json.partial! '/matches/match', match: match
end
