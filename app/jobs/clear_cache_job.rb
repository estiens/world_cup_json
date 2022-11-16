class ClearCacheJob < ApplicationJob
  queue_as :scheduler

  def perform
    Rails.cache.clear
  end
end
