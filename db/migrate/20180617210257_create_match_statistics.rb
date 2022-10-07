# frozen_string_literal: true

class CreateMatchStatistics < ActiveRecord::Migration[5.0]
  def change
    create_table :match_statistics do |t|
      t.references :team, null: false
      t.references :match, null: false
      %i[attempts_on_goal on_target off_target blocked woodwork
         corners offsides ball_possession pass_accuracy num_passes
         passes_completed distance_covered balls_recovered tackles
         clearances yellow_cards red_cards fouls_committed].each do |stat|
        t.integer stat
      end
      t.timestamps null: false
    end
    add_column :matches, :stats_complete, :boolean, null: false, default: false
  end
end
