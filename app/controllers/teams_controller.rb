class TeamsController < ApplicationController

  def index
    @teams=Team.all
    render json: @teams.to_json(only: [:country, :alternate_name, :fifa_code, :group_id])
  end

  def results
    @teams=Team.all
    render json: @teams.to_json(except: [:id, :created_at])
  end
end
