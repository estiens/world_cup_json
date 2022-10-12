class MatchUpdateSelfJob < ApplicationJob
  queue_as :noscrape

  def perform(match_id)
    match = Match.find(match_id)
    MatchWriter.new(match: match).write_match
  end
end
