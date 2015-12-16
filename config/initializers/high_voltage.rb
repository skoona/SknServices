# config/initializers/high_voltage.rb
# ref: https://github.com/thoughtbot/high_voltage/blob/master/README.md
#
HighVoltage.configure do |config|
  config.route_drawer = HighVoltage::RouteDrawers::Root
end