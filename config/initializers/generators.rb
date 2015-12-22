##
# RSpec Configurations
# g.orm setting prevents 'rake spec' from doing db:prepare, etc
# Turn off active_record in Rake spec task
# -- either do it here or in the rspec.rake task
# -- ref: http://stackoverflow.com/questions/4140081/rake-spec-migrates-the-database-every-time
# -- ref: http://edgeguides.rubyonrails.org/configuring.html
##

Rails.application.config.generators do |g|
  g.test_framework :rspec,
                   :fixtures => true,
                   :model_specs => false,
                   :view_specs => false,
                   :helper_specs => false,
                   :routing_specs => false,
                   :controller_specs => false,
                   :request_specs => true
  g.fixture_replacement :factory_girl, :dir => "spec/factories"
end
