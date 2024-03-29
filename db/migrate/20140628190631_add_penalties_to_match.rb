# frozen_string_literal: true

class AddPenaltiesToMatch < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :home_team_penalties, :integer
    add_column :matches, :away_team_penalties, :integer
  end
end
