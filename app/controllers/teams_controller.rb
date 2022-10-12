# frozen_string_literal: true

class TeamsController < BaseApiController
  def index
    @teams = Team.all.includes(:group)
    @groups = Group.all.includes(:teams)
    render :index
  end

  def show
    @team = Team.find_by(id: params[:id])
    @team = Team.find_by(fifa_code: params[:id].upcase)
    @team ||= Team.find_by(country: params[:id].upcase)
    raise ActiveRecord::RecordNotFound, 'Team Not Found' unless @team

    @last_match = @team.last_match
    @next_match = @team.next_match
  end
end
