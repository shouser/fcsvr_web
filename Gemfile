source :rubygems

gem "rails", ">= 3.0.3"
gem "rack"
gem "rake", "~> 0.8.7"
gem "clearance", "~> 0.10.1"
gem "haml"
gem "sass"
gem "open4"
gem "high_voltage"
gem "hoptoad_notifier"
gem "RedCloth", :require => "redcloth"
gem "paperclip"
gem "will_paginate"
gem "validation_reflection"
gem "formtastic"
#gem "mysql"
gem "flutie"
gem "dynamic_form"
gem "sqlite3"
gem "fcs", :path => "#{File.expand_path(__FILE__)}/../vendor/gems/fcs-0.1.12"
gem "rubytree"
gem "net-ssh"
gem "json"

# RSpec needs to be in :development group to expose generators
# and rake tasks without having to type RAILS_ENV=test.
group :development, :test do
  gem "rspec-rails", "~> 2.4.0"
  gem "ruby-debug",   :platforms => :mri_18
  gem "ruby-debug19", :platforms => :mri_19
end

group :test do
  gem "cucumber-rails"
  gem "factory_girl_rails"
  gem "bourne"
  gem "capybara"
  gem "database_cleaner"
  gem "fakeweb"
  gem "sham_rack"
  gem "nokogiri"
  gem "timecop"
  gem "treetop"
  gem "shoulda"
  gem "launchy"
  gem "akephalos"
  gem "thin"
end
