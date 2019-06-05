# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :type
      t.string :player
      t.string :time
      t.boolean :home_team
      t.integer :match_id

      t.timestamps
    end
  end
end
