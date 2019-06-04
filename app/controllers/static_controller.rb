class StaticController < ApplicationController
  def index
    @yesterday_matches = Match.yesterday.order('datetime ASC')
    @today_matches = Match.today.order('datetime ASC')
    @tomorrow_matches = Match.tomorrow.order('datetime ASC')
    @next_match = Match.next
  end
end
