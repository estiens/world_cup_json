# frozen_string_literal: true

WorldCupJson::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  get '/teams', to: 'teams#index', defaults: { format: 'json' }
  get '/teams/results', to: 'teams#results', defaults: { format: 'json' }
  get '/teams/group_results', to: 'teams#group_results', defaults: { format: 'json' }
  get '/matches', to: 'matches#index', defaults: { format: 'json' }
  get '/matches/index', to: 'matches#index', defaults: { format: 'json' }
  get '/matches/complete', to: 'matches#complete', defaults: { format: 'json' }
  get '/matches/current', to: 'matches#current', defaults: { format: 'json' }
  get '/matches/future', to: 'matches#future', defaults: { format: 'json' }
  get '/matches/country', to: 'matches#country', defaults: { format: 'json' }
  get '/matches/today', to: 'matches#today', defaults: { format: 'json' }
  get '/matches/tomorrow', to: 'matches#tomorrow', defaults: { format: 'json' }
  get '/matches/:id', to: 'matches#show'
  get '/matches/fifa_id/:id', to: 'matches#show'
  # You can have the root of your site routed with "root"
  root 'static#index'

  get '*path' => 'errors#path_not_found', defaults: { format: 'json' }
  put '*path' => 'errors#unprocesssable_entity', defaults: { format: 'json' }
end
