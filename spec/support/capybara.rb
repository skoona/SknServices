# Capybara.asset_host = 'http://localhost:3000'

# Tell it to use xpath rather than css selectors
Capybara.configure do |config|
  # config.default_host = 'test.host'
  # config.app_host     = 'test.host'
  # config.asset_host   = 'test.host'
  # config.server_port  = 3200
  config.default_driver = :rack_test
  config.javascript_driver = :poltergeist
  # config.default_wait_time = 30
  # config.default_selector = :css   #:xpath
  # config.run_server = true
  # config.always_include_port = true
end

Capybara.register_driver :rack_test do |app|
   Capybara::RackTest::Driver.new(app)
   # Capybara::RackTest::Driver.new(app, :browser => :safari)
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {timeout: 300})
  #Capybara::Poltergeist::Driver.new(app, {timeout: 300, debug: true})
end

# Ref: https://github.com/mattheworiordan/capybara-screenshot
# screenshot_and_save_page
# screenshot_and_open_image
#
# Rack::Test Driver does not support screenshots; :poltergeist does support it
#
Capybara::Screenshot.autosave_on_failure = true
Capybara::Screenshot.prune_strategy = :keep_last_run
Capybara.save_path = "tmp/capybara"
Capybara::Screenshot.append_timestamp = true
Capybara::Screenshot::RSpec.add_link_to_screenshot_for_failed_examples = true
Capybara::Screenshot::RSpec::REPORTERS["RSpec::Core::Formatters::HtmlFormatter"] = Capybara::Screenshot::RSpec::HtmlEmbedReporter

