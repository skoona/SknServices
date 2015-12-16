# config/initializers/high_voltage.rb
# ref: https://github.com/thoughtbot/high_voltage/blob/master/README.md
#

##
#  We get pages/show/id:about, Rather than high_voltage/about
##

HighVoltage.configure do |config|
  config.route_drawer = HighVoltage::RouteDrawers::Root
end