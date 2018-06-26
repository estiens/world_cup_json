object @match_statistic
cache @match_statistic, expires_in: @cache_time
node(:country) { root_object.team.country }
attributes :attempts_on_goal, :on_target, :off_target, :blocked, :woodwork,
           :corners, :offsides, :ball_possession, :pass_accuracy, :num_passes,
           :passes_completed, :distance_covered, :balls_recovered, :tackles,
           :clearances, :yellow_cards, :red_cards, :fouls_committed, :tactics,
           :starting_eleven, :substitutes
