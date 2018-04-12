#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'support/utilities'
require 'support/test_users'
require 'support/test_data_serializers'

ActionMailer::Base.delivery_method = :test

RSpec.configure do |config|

  Kernel.srand config.seed

  if 10 > config.files_to_run.length   # .one?
    config.formatter = :documentation
  else
    config.formatter = :progress
  end

  config.order = :random
  config.color = true
  config.tty = false
  config.warnings = false

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.silence_filter_announcements = true

  # TODO: Causes the Feature tag to fail in Capybara specs
  # config.disable_monkey_patching!  # -- breaks rspec runtime  requires Rspec.describe vs describe

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true # prefer true
  end

  config.include TestUsers
  config.include Utilities
  config.include TestDataSerializers

end
