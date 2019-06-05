# frozen_string_literal: true

class AddTeamIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :team_id, :integer
  end
end
