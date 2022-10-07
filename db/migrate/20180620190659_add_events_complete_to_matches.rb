# frozen_string_literal: true

class AddEventsCompleteToMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :events_complete, :boolean, null: false, default: false
  end
end
