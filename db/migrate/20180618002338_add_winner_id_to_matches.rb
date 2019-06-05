# frozen_string_literal: true

class AddWinnerIdToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :winner_id, :integer
    add_column :matches, :draw, :boolean, default: false, null: false
    add_index :matches, :winner_id
  end
end
