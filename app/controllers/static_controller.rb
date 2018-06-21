class StaticController < ApplicationController
  def index
    @today_matches = Match.today.order('datetime ASC')
    @tomorrow_matches = Match.tomorrow.order('datetime ASC')
  end
end
