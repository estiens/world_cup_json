# frozen_string_literal: true

class StaticController < ApplicationController
  def index
    request.format = :html

    @yesterday_matches = Match.yesterday.order('datetime ASC')
    @today_matches = Match.today.order('datetime ASC')
    @tomorrow_matches = Match.tomorrow.order('datetime ASC')
    @current_matches = Match.in_progress
  end
end
