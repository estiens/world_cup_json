class RemoveOldFieldsFromMatchStats < ActiveRecord::Migration[7.0]
  def fields_to_remove
    %i[

      distance_covered
      balls_recovered
      woodwork
      clearances
      ball_possession
      pass_accuracy
    ]
  end

  def change
    fields_to_remove.each do |field|
      remove_column :match_statistics, field.to_sym
    end
  end
end
