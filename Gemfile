source 'https://rubygems.org'
ruby "1.9.3"

#gem 'rails', '3.2.13'
gem 'bootstrap-sass','~> 3.1.1'
gem 'faker', '1.0.1' # to create realistic sample db data
gem 'will_paginate', '3.0.3'
gem 'bootstrap-will_paginate', '0.0.9'

gem 'activesupport',      '3.2.13', :require => 'active_support'
gem 'actionpack',         '3.2.13', :require => 'action_pack'
gem 'actionmailer',       '3.2.13', :require => 'action_mailer'
gem 'railties',           '3.2.13', :require => 'rails'
gem 'tzinfo'
gem 'libxml-ruby'
gem 'nokogiri'
gem 'thin'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Gems used only for assets and not required
# in production environments by default.
#group :assets do
  gem 'sass-rails',   '>= 3.2'
  gem 'coffee-rails', '3.2.2'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '1.2.3'
#end

gem 'jquery-rails', '~>2.1'

%w{core types constraints validations migrations aggregates transactions timestamps do-adapter rails active_model postgres-adapter ar-finders}.each do |dmgem|
  gem "dm-#{dmgem}"
end

group :production do
  gem 'pg', '0.12.2'
  #gem 'sqlite3', '1.3.5'  
end

group :test do
  gem 'capybara', '1.1.2'
  gem 'factory_girl_rails', '4.2.1'  
end

group :development, :test do
  gem 'rspec-rails', '2.11.0'
  gem 'debugger'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'
