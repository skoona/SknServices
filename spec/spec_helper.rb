#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'support/utilities'
require 'support/test_data_serializers'

RSpec.configure do |config|

  Kernel.srand config.seed

  if config.files_to_run.one?
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

  # TODO: Causes the Feature tag to fail in Capybara specs
  # config.disable_monkey_patching!  # -- breaks rspec runtime

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true # prefer true
  end

  config.include Utilities
  config.include TestDataSerializers

end
