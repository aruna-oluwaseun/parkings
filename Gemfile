# frozen_string_literal: true
ruby '~> 2.7.8'
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
gem 'ffi', '~> 1.15.5'

gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'rails', '~> 5.2.1'
gem 'pg'
gem 'webpacker'
gem 'bootsnap', require: false

gem 'bootstrap'
gem 'devise'
gem 'active_interaction', '~> 3.6' # form-object
gem 'phony_rails' # phone validation
gem 'active_model_serializers'
gem 'responders'
gem 'apipie-rails' # api documentation
gem 'rack-cors', require: 'rack/cors'
gem 'tzinfo-data'
gem 'action_policy', github: 'palkan/action_policy'
gem 'effective_addresses'
gem 'credit_card_validations'
gem 'paper_trail'
gem 'spreadsheet_architect'
gem 'http'
gem 'money'
gem 'sentry-raven'
gem 'slack-notifier'
gem 'slim-rails'
gem 'jquery-rails'
gem 'sass-rails'
gem 'font-awesome-rails'

# images
gem 'active_storage_base64'
gem 'active_storage_validations'
gem 'mini_magick'

gem 'pagy'
gem 'api-pagination'

gem 'faker'

# background processing, requires redis
gem 'sidekiq', '~> 6.5'


# Log format
gem 'lograge'

# Push notifications
gem 'fcm'

# Pick up time zone by location
gem 'timezone'

# Ruby wrapperer around the Google Places API
gem 'google_places'

group *%i[development test] do
  gem 'awesome_print'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.8'
  gem 'rubocop', require: false
end

group *%i[development production] do
  gem 'uglifier'
  gem 'coffee-rails'
  gem 'jbuilder'
  gem 'administrate'
  gem 'json2table'
  gem 'redis-rails'
  gem 'uglifier'

  # Transform HTML into PDF
  gem 'grover'
end

group :test do
  gem 'factory_bot'
  gem 'database_cleaner', '>=1.6.0'
  gem 'simplecov', require: false
  gem 'simplecov-cobertura'
  gem 'shoulda-matchers', '~> 4.0'
  gem "fakeredis", require: "fakeredis/rspec"
end

group :development do
  gem 'puma'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background.
  gem 'listen'
  gem 'spring'
  gem 'bullet'
  gem 'spring-watcher-listen'
  # Project Documentation
  gem 'yard'
  gem 'redcarpet'
end

group :production do
  gem 'unicorn'
end
