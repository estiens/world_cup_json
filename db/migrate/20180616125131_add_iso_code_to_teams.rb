# frozen_string_literal: true

class AddIsoCodeToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :iso_code, :string
  end
end
