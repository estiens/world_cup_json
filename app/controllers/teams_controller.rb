class TeamsController < ApplicationController

  def index
    @teams=Team.all
    render json: @teams.to_json(only: [:country, :alternate_name, :fifa_code, :group_id]), :callback => params['callback']
  end

  def results
    @teams=Team.find(:all, :order => "group_id, wins DESC, draws DESC")
    render json: @teams.to_json(except: [:id, :created_at]), :callback => params['callback']
  end

  def new_results
    @teams = Team.find(:all, :order => "id")
    render 'team_results.json.rabl'
  end

  def group_results
    @groups = Group.all
    render 'group_results.json.rabl'
  end
end
