class ClearCacheJob < ApplicationJob
  queue_as :scheduler

  def perform
    Rails.cache.clear
    Team.all.each(&:save)
    Match.today.each(&:save)
  end
end
