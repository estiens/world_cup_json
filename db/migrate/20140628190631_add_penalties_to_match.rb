# frozen_string_literal: true

class AddPenaltiesToMatch < ActiveRecord::Migration
  def change
    add_column :matches, :home_team_penalties, :integer
    add_column :matches, :away_team_penalties, :integer
  end
end
