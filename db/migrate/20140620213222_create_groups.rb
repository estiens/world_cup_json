# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :groups do |t|
      t.string :letter, null: false
      t.timestamps
    end
  end
end
