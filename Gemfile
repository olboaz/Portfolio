source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.12'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.1.4'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5'
# Use Puma as the app server
gem 'puma', '~> 8.0', '>= 8.0.2'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'letter_opener', '1.10.0', group: :development
gem 'cloudinary', '2.4.5'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Authentification
gem 'devise', '>= 5.0.4', '< 6.0'

# Authorization
gem 'pundit', '2.5.2'

gem 'autoprefixer-rails'
gem 'font-awesome-sass', '6.7.2'
gem 'simple_form', '5.4.1'
group :development, :test do  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'dotenv-rails', '~> 3.2'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '4.3.0'
  gem 'listen', '~> 3.2'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver', '>= 4.14'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'nokogiri', '~> 1.19'
gem 'minitest', '~> 5.25'
gem "rack-attack", "~> 6.7"
gem "bigdecimal"
