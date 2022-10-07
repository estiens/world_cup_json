# frozen_string_literal: true

class AddVenueToMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :venue, :string
    remove_column :matches, :match_number, :integer
  end
end
