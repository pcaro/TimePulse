# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

if ENV["CODECLIMATE_REPO_TOKEN"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec

  #config.backtrace_clean_patterns = {}

  config.include Devise::TestHelpers, :type => :view
  config.include Devise::TestHelpers, :type => :controller
  config.include Devise::TestHelpers, :type => :helper

  config.after(:each, :type => :view)  do
    sign_out :user
  end

  config.after(:each, :type => :controller)  do
    sign_out :user
  end

  config.use_transactional_fixtures = false

  DatabaseCleaner.strategy = :transaction

  config.before :all, :type => :feature do
    Rails.application.config.action_dispatch.show_exceptions = true
    DatabaseCleaner.clean_with :truncation
    load 'db/seeds.rb'
  end

  config.after :all, :type => :feature do
    Timecop.return
    DatabaseCleaner.clean_with :truncation
    load 'db/seeds.rb'
  end

  config.before :each, :type => proc{ |value| value != :feature } do
    DatabaseCleaner.start
  end
  config.after :each, :type => proc{ |value| value != :feature } do
    DatabaseCleaner.clean
  end

  config.before :suite do
    DatabaseCleaner.clean_with :truncation
    load 'db/seeds.rb'
  end

  config.include(SaveAndOpenOnFail, :type => :feature)
  config.include(BrowserHelpers, :type => :feature)

  #JL is putting this in here - if it causes problems contact him
  require 'cadre/rspec'
  config.run_all_when_everything_filtered = true
  if config.formatters.empty?
    config.add_formatter(:progress)
  end
  config.add_formatter(Cadre::RSpec::NotifyOnCompleteFormatter)
  config.add_formatter(Cadre::RSpec::QuickfixFormatter)
end

def content_for(name)
  view.instance_variable_get("@content_for_#{name}")
end
