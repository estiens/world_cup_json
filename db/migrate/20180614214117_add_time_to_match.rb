# frozen_string_literal: true

class AddTimeToMatch < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :time, :string
  end
end
