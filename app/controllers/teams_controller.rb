class TeamsController < ApplicationController
  after_filter :set_content_type
  protect_from_forgery with: :null_session


  def index
    @teams=Team.all
    render json: @teams.to_json(only: [:country, :alternate_name, :fifa_code, :group_id]), :callback => params['callback']
  end

  def results
    @teams = Team.all
    render json: 'team_results.json.rabl', :callback => params['callback']
  end

  def group_results
    @groups = Group.all
    render json: 'group_results.json.rabl', :callback => params['callback']
  end
end
