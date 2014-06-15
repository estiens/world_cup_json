class MatchesController < ApplicationController

def index
    @matches = Match.all.order(:match_number)

    respond_to do |format|
      format.json {render :json => @matches.to_json(
        :include => {
          :home_team => {
            :only => :country
          }
        })
      }
    end
  end
end


