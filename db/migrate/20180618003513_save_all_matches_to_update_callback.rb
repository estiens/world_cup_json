# frozen_string_literal: true

class SaveAllMatchesToUpdateCallback < ActiveRecord::Migration[5.0]
  def change
    Match.all.each(&:save)
  end
end
