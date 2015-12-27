# Capybara.asset_host = 'http://localhost:3000'

# Tell it to use xpath rather than css selectors
Capybara.configure do |config|
  config.default_host = "http://www.example.com"
  config.app_host   = 'http://www.example.com'
  config.asset_host = 'http://localhost:3000'

  #config.server_port = 3000
  #config.default_selector = :xpath
end

Capybara.register_driver :mechanize do |app|
  Capybara::Mechanize::Driver.new(app, :browser => :firefox)
end
