# frozen_string_literal: true

class ChangeEventTypetoSOmethingElse < ActiveRecord::Migration
  def change
    rename_column :events, :type, :type_of_event
  end
end
