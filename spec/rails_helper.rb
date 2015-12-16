# This file is copied to spec/ when you run 'rails generate rspec:install'
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

# Tell it to use xpath rather than css selectors
Capybara.configure do |config|
  config.default_host = "http://www.example.com"
  config.app_host   = 'http://www.example.com'
  #config.server_port = 3000
  #config.default_selector = :xpath
end

Capybara.register_driver :mechanize do |app|
  Capybara::Mechanize::Driver.new(app, :browser => :firefox)
end

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  # Include support methods
  config.include AuthenticationHelpers
  config.include ApplicationHelper
  config.include Utilities
  config.include TestDataSerializers

  config.include Rails.application.routes.url_helpers
  config.include Rails.application.routes.mounted_helpers

  # Turn on FactoryGirl
  # ref: https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
  config.include FactoryGirl::Syntax::Methods

  config.infer_spec_type_from_file_location!

  Kernel.srand config.seed

  config.order = :random
  config.color = true
  config.tty = false

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # TODO: Causes the Feature tag to fail in Capybara specs
  # config.disable_monkey_patching!  # -- breaks rspec runtime

  config.warnings = false

  if config.files_to_run.one?
    config.formatter = :documentation
  else
    config.formatter = :progress  #:html, :textmate, :documentation
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true # prefer true
  end


  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    # Warden.test_reset!
  end

end
