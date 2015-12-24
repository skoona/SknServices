# This file is copied to spec/ when you run 'rails generate rspec:install'
if $LOADED_FEATURES.grep(/spec\/rails_helper\.rb/).any?
  begin
    raise "foo"
  rescue => e
    puts <<-MSG
  ===================================================
  It looks like spec_helper.rb has been loaded
  multiple times. Normalize the require to:
    require "spec/spec_helper"
  Things like File.join and File.expand_path will
  cause it to be loaded multiple times.
  Loaded this time from:
    #{e.backtrace.join("\n    ")}
  ===================================================
    MSG
  end
end

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'capybara/rspec'
require 'capybara/rails'

require "rack_session_access/capybara"
require 'capybara/mechanize'
require 'database_cleaner'

require 'spec_helper'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# RackSessionAccess config
Rails.application.config do
  config.middleware.use RackSessionAccess::Middleware
end

# fixes: 'Missing host to link to! Please provide the :host parameter,
#         set default_url_options[:host], or set :only_path to true'
Rails.application.routes.default_url_options[:host] = 'www.example.com'

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  # Include support methods
  config.include AuthenticationHelpers
  config.include ApplicationHelper

  config.include Rails.application.routes.url_helpers
  config.include Rails.application.routes.mounted_helpers

  config.include Warden::Test::Helpers

  # Turn on FactoryGirl
  # ref: https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    load Rails.root.join("db/seeds.rb")
  end

  config.after(:each) do
    Warden.test_reset!
  end

end
