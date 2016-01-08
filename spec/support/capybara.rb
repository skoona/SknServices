# Capybara.asset_host = 'http://localhost:3000'

# Tell it to use xpath rather than css selectors
Capybara.configure do |config|
  config.default_host = 'http://localhost'
  config.app_host     = 'http://localhost'
  config.asset_host   = 'http://localhost'
  config.server_port  = 3200
  config.default_driver = :rack_test
  config.javascript_driver = :poltergeist
  config.default_wait_time = 30
  config.default_selector = :css   #:xpath
  config.run_server = true
  config.always_include_port = true
end

Capybara.register_driver :rack_test do |app|
   Capybara::RackTest::Driver.new(app)
   # Capybara::RackTest::Driver.new(app, :browser => :safari)
end

Capybara.register_driver :mechanize do |app|
  Capybara::Mechanize::Driver.new(app)
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {timeout: 300})
  #Capybara::Poltergeist::Driver.new(app, {timeout: 300, debug: true})
end
