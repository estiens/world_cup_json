# frozen_string_literal: true

class AddColumnToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :fifa_id, :string
  end
end
