source 'https://rubygems.org'

gem 'rails', '3.2.17'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'
gem 'mysql2', '~>0.3'


# Gems used only for assets and not required
# in production environments by default.
#group :assets do
  #gem 'sass-rails',   '~> 3.2.3'
  #gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  #gem 'uglifier', '>= 1.0.3'
#end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
gem 'haml-rails', '~> 0.4'
gem 'sass-rails',   '~> 3.2.3'
gem 'faraday', '~> 0.8'
gem 'js-routes', '~> 0.7'
gem 'newrelic_rpm', '~> 3.6'
gem 'uuidtools', '~> 2.1'
gem 'addressable', '~> 2.3', require: 'addressable/uri'
gem 'roo', '~> 1.13'
gem 'rabl', '= 0.7.9'
gem 'dalli', '~> 2.6'
gem 'validate_email', '~> 0.1'
gem "i18n-js", "~> 2.1"
gem 'carmen-rails', '~> 1.0'
gem 'rack-cors', '~> 0.2'
gem 'turbolinks'
gem 'kaminari'
#gem 'log4r', '~> 1.0.0'
gem 'better_errors', '~> 1.1.0'
gem 'binding_of_caller'

group :assets do
  #gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem "execjs"
  gem "therubyracer"
  gem 'uglifier', '>= 1.0.3'
  #gem 'sass-rails',   '~> 3.2'
  gem 'asset_sync', '~> 1.0.0'
end

# Medidata gems
gem 'sandman-rails', git: 'git@github.com:mdsol/sandman-rails.git', branch: 'v0.2.8'
gem 'dice_bag', git: 'git@github.com:mdsol/dice_bag.git', tag: 'v0.7'
gem 'mdsol-tools', git: 'git@github.com:mdsol/mdsol-tools.git', tag: 'v0.3.2'
gem 'eureka-client', git: 'git@github.com:mdsol/eureka-client.git', tag: 'v2.3.2'
gem 'eureka_tools', git: 'git@github.com:mdsol/eureka_tools.git', branch: 'develop'
gem 'api_pagination', git: 'git@github.com:mdsol/api_pagination.git', tag: 'v0.0.9'
gem 'mauth-client', git: 'git@github.com:mdsol/mauth-client.git', tag: 'v2.6.3'
gem 'rack-app_status', :git => 'git@github.com:mdsol/rack-app_status.git', :tag => '0.1.2', :require => 'rack/app_status'
gem 'strong_parameters', git: 'git@github.com:mdsol/strong_parameters.git', tag: 'v1.0.1dev'
gem 'rack-cache', git: 'git@github.com:mdsol/rack-cache.git', branch: 'develop'
gem 'grandmaster', git: 'git@github.com:mdsol/grandmaster.git', tag: 'v1.4.0', require: 'checkmate/grandmaster'
gem 'mysql2_config', :git => 'git@github.com:mdsol/mysql2_config.git', :branch => 'master'
gem 'impersonation_middleware', :git => 'git@github.com:mdsol/impersonation_middleware.git', tag: 'v0.0.2'
gem 'zipkin-tracer', :git => 'git@github.com:mszenher/zipkin-tracer.git', :require => 'zipkin-tracer', :tag => 'v0.4.0'
gem 'thin', '1.5.1' # this is required by zipkin-tracer; hopefully, this dependency will be gone soon
gem 'tamashii', git: 'git@github.com:mdsol/tamashii.git', tag: 'v1.5.1'
gem 'pb_numbers', git: 'git@github.com:mdsol/pb_numbers.git', tag: 'v1.0.0'


#TODO: Move to dev and test group when production starts consuming live services
#gem 'factory_girl', '~> 3.5'
#gem 'faker', '~> 1.0'

group :development, :test do
  gem 'kender', git: 'git@github.com:mdsol/kender.git', tag: 'v0.1.7'
  gem 'shamus', git: 'git@github.com:mdsol/shamus.git', branch: 'develop'
  gem 'brakeman', '~> 2.0' # test security of the project itself
  gem 'bundler-audit', '~> 0.1' # test security of gems in the project
  gem 'debugger', '=1.1.4'
  #TODO uncomment these once a fix is found to run jasmine (jquery inclusion problem)
  gem 'rspec', '~> 2.14'
  gem 'selenium-webdriver', '~> 2.35'
  gem 'webmock', '~> 1.11'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'timecop', '~> 0.4'
  gem 'capybara', '~> 2.2'
  gem 'rubocop'
  gem 'rubocop-checkstyle_formatter', require: false
  gem 'jslint', '~> 1.2.0'
  gem "pry", '~> 0.9'
  gem "pry-nav", '~> 0.2'
  gem 'pry-stack_explorer', '~> 0.4.9'
end


group :test do
  gem 'database_cleaner', '~> 0.7'
  gem 'cucumber'
  gem 'cucumber-rails', '~> 1.3', require: false
  gem 'jasmine', '~> 1.3.2'
  #gem 'jasmine-rails', '~> 0.0', require: false
  gem 'jasmine-phantom', '~> 0.0.9'
  gem 'rspec-rails', '~> 2.14'
  gem 'pickle', '~> 0.4'
  gem 'launchy', '~> 2.1.2'
  gem 'nokogiri', '~> 1.6'
  gem 'simplecov', '~> 0.6', require: false
  gem 'poltergeist', '~> 1.5'
  gem 'i18n-missing_translations', '~> 0.0'
end