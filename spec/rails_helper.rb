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
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'spec_helper'

require 'warden/test/helpers'
require 'warden/test/warden_helpers'

require 'capybara/rspec'
require 'capybara/rails'
require "rack_session_access/capybara"
require 'capybara-screenshot/rspec'
require 'capybara/poltergeist'
require 'database_cleaner'

# Do we want code coverage
if "true".eql?(ENV['COVERAGE'])
  require 'simplecov'
  require 'code_coverage'
end

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# fixes: 'Missing host to link to! Please provide the :host parameter,
#         set default_url_options[:host], or set :only_path to true'
Rails.application.routes.default_url_options[:host] = 'http://test.localdomain.com'

# Checks for pending migration and applies them before tests are run.
ActiveRecord::Migration.maintain_test_schema!

ActionView::TestCase::TestController.send :include, Secure::ControllerAccessControl

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  # Include routing helpers
  config.include Rails.application.routes.url_helpers
  config.include Rails.application.routes.mounted_helpers

  # Include support methods
  config.include ApplicationHelper
  config.include Warden::Test::WardenHelpers          # asset_paths, on_next_request, test_reset!
  config.include Warden::Test::Helpers                # login_as(u, opts), logout(scope), CALLS ::Warden.test_mode!
  config.include Warden::Test::ControllerHelpers, type: :controller
  config.include FeatureHelpers  #, type: :feature       # logged_as(user) session injection for cucumber/capybara

  config.before(:each) do
    Capybara.use_default_driver       # switch back to default driver
    # Capybara.default_host = 'http://test.host'
  end

  config.append_after(:each) do
    Warden.test_reset!
    # Capybara.current_session.driver.reset!
    Capybara.reset_sessions!
  end

  def sign_in(user, opts=nil)
    warden.set_user(user,opts)
  end

  def app
    Rails.application
  end

end
