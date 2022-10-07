# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.1.1'

gem 'rails'

gem 'pg'

gem 'chronic'
gem 'clockwork'
gem 'haml-rails'
gem 'httparty'
gem 'jbuilder'
gem 'puma'
gem 'rack-attack'
gem 'rack-cors', require: 'rack/cors'
gem 'redis'

group :production do
  gem 'scout_apm'
end

group :development do
  gem 'derailed_benchmarks'
  gem 'stackprof'
end

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
  gem 'rubocop'
end
