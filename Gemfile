source 'https://rubygems.org'
ruby '3.1.1'

gem 'rails', '~> 7.0'

gem 'pg', '~> 1.4'

gem 'chronic', '~> 0.10'
gem 'good_job', '~> 3.4'
gem 'haml-rails', '~> 2.1'
gem 'httparty', '~> 0.20'
gem 'jbuilder', '~> 2.11'
gem 'puma', '~> 5.6'
gem 'rack-attack', '~> 6.6'
gem 'rack-cors', '~> 1.1', require: 'rack/cors'
gem 'redis', '~> 5.0'

group :production do
  gem 'fly-ruby'
end

group :development do
  gem 'derailed_benchmarks', '~> 2.1'
  gem 'stackprof', '~> 0.2'
end

group :development, :test do
  gem 'better_errors', '~> 2.9'
  gem 'binding_of_caller', '~> 1.0'
  gem 'pry-rails', '~> 0.3'
  gem 'rubocop', '~> 1.36'
end
