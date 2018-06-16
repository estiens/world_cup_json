# frozen_string_literal: true

class TeamsController < BaseApiController
  def index
    @teams = Team.all
    render 'team_index.json.rabl', callback: params['callback']
  end

  def results
    @teams = Team.all
    render 'team_results.json.rabl', callback: params['callback']
  end

  def group_results
    @groups = Group.all
    render 'group_results.json.rabl', callback: params['callback']
  end
end
