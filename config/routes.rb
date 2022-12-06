WorldCupJson::Application.routes.draw do
  root 'static#index'
  mount GoodJob::Engine => 'good_job'

  get '/teams', to: 'teams#index'
  get '/teams/:id', to: 'teams#show'

  get '/matches', to: 'matches#index'
  get '/matches/index', to: 'matches#index'
  get '/matches/complete', to: 'matches#complete'
  get '/matches/current', to: 'matches#current'
  get '/matches/future', to: 'matches#future'
  get '/matches/country/:country', to: 'matches#country'
  get '/matches/yesterday', to: 'matches#yesterday'
  get '/matches/today', to: 'matches#today'
  get '/matches/tomorrow', to: 'matches#tomorrow'
  get '/matches/:id', to: 'matches#show'
  get '*path', :to => 'base_api#routing_error'
  put '*path', :to => 'base_api#routing_error'
end
