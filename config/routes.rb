WorldCupJson::Application.routes.draw do
  root 'static#index'

  get '/teams', to: 'teams#index'
  get '/teams/:id', to: 'teams#show'

  get '/matches', to: 'matches#index'
  get '/matches/index', to: 'matches#index'
  get '/matches/complete', to: 'matches#complete'
  get '/matches/current', to: 'matches#current'
  get '/matches/future', to: 'matches#future'
  get '/matches/country', to: 'matches#country'
  get '/matches/today', to: 'matches#today'
  get '/matches/tomorrow', to: 'matches#tomorrow'
  get '/matches/:id', to: 'matches#show'
  get '/matches/fifa_id/:id', to: 'matches#show'

  get '*path' => 'errors#path_not_found'
  put '*path' => 'errors#unprocesssable_entity'
end
