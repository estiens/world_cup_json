class TeamsController < ApplicationController

  def index
    @teams=Team.all
    render json: @teams.to_json(only: [:country, :alternate_name, :fifa_code, :group_id])
  end

  def results
    @teams=Team.all
    render json: @teams.to_json(except: [:id, :created_at])
  end

  def new_results
    @teams = Team.all
    render 'team_results.json.rabl'
  end

   def group_results
    @groups = Group.all
    render 'group_results.json.rabl'
  end
end
