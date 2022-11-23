class AddMatchStats < ActiveRecord::Migration[7.0]

  def values
    %w[attempts_on_goal_against
       blocked
       corners
       fouls_committed
       free_kicks
       goal_kicks
       num_passes
       off_target
       offsides
       on_target
       passes_completed
       penalties
       penalties_scored
       red_cards
       throw_ins
       yellow_cards]
  end

  def change
    values.each do |value|
      add_column(:match_statistics, value.to_sym, :integer, if_not_exists: true)
    end
  end
end
