source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'capybara', group: %i[development test]
gem 'dotenv-rails', groups: %i[development test]
gem 'rails', '~> 5.2.0'
gem 'rspec_api_documentation', group: %i[development test]

# Use pg as the database for Active Record
gem 'apitome'
gem 'pg'
gem 'responders'

# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
gem 'jquery-minicolors-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'simple_form'

gem 'addressable'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'platform-api', '~> 2.1'

gem 'stitches'

gem 'rollbar'

gem 'oauth'

# gem 'twitter', git: 'https://github.com/sferik/twitter.git'
gem 'twitter', git: 'https://github.com/sqlninja/twitter.git'
# gem 'twitter', path: '/Users/johnhenderson/code/rails/twitter'

# Used for flagging questionable content
gem 'obscenity'

gem 'redis'

gem 'sidekiq'

gem 'simple_scheduler'

gem 'paperclip'

gem 'aws-sdk'

gem 'aws-sdk-s3'

gem 'rack-cors', require: 'rack/cors'

gem 'acts-as-taggable-on', '~> 6.0'

gem 'sorcery'
gem 'sorcery-jwt'

gem 'jwt'
gem 'rolify'

gem 'faraday'
gem 'rest-client'
# for sms
gem 'ruby-bandwidth'

# https://github.com/jcypret/hashid-rails
gem 'hashid-rails', '~> 1.0'

gem 'best_in_place', git: 'https://github.com/bernat/best_in_place.git', branch: 'master'
# gem 'diproart-bulma-rails', git: 'https://github.com/diproart/bulma-rails'
# gem 'diproart-bulma-rails', github: 'diproart/bulma-rails'
gem 'bulma-extensions-rails'
gem 'bulma-rails', '~> 0.7.2'
# gem 'font-awesome-rails'

# https://github.com/FortAwesome/font-awesome-sass
gem 'font-awesome-sass', '~> 5.5.0'
gem 'jquery-slick-rails'
gem 'rails_autolink'

gem 'browser-timezone-rails'
gem 'calculate-all'
gem 'chartkick'
gem 'groupdate'
gem 'hightop'
gem 'local_time'
# gem 'semantic-ui-sass'
# gem 'forest_liana'

# gem 'activeadmin'
# gem 'arctic_admin' #Theme: https://github.com/cle61/arctic_admin
# gem 'active_admin_versioning'
# gem 'active_admin-humanized_enum'

# This is the mailchimp gem
gem 'gibbon'

gem 'will_paginate', '~> 3.1.1'
gem 'will_paginate-bulma'

gem 'time_difference'

# gem 'celluloid'
# gem 'concurrent-ruby', require: 'concurrent'
gem 'activerecord-import'
gem 'parallel'
gem 'upsert'

# These gems are here to allow for migration of data from existing RS db
gem 'bson_ext'
gem 'mongoid', '~> 7.0'

gem 'progress'
gem 'ruby-progressbar'

gem 'active_record_doctor', group: :development
gem 'lol_dba'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'faker', git: 'https://github.com/stympy/faker.git', branch: 'master'
  gem 'foreman'
  gem 'pry-byebug'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
