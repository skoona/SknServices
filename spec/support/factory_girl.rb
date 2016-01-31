# Turn on FactoryGirl
# ref: https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
