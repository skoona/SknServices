require_relative 'boot'

require 'rails/all'
# require 'logging'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if defined? JRUBY_VERSION
  require 'java'
end

module SknService
  class Application < Rails::Application

    config.autoload_paths += Dir["#{Rails.root}/lib/**/"]

    config.eager_load_paths << Rails.root.join('lib')

    config.time_zone = Settings.Packaging.time_zone

    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    config.active_record.schema_format = :ruby
    config.active_record.dump_schemas = :all

# Add the PERF type
# https://github.com/TwP/logging/blob/master/examples/custom_log_levels.rb

    Logging.init(:debug, :info, :perf, :warn, :success, :error, :fatal)
    dpattern = Logging.layouts.pattern({ pattern: '%d %c:%-5l %m\n', date_pattern: '%Y-%m-%d %H:%M:%S.%3N' })
    astdout = Logging.appenders.stdout( 'stdout', :layout => dpattern)
    arolling = Logging.appenders.rolling_file( 'rolling_log', :filename => "./log/#{Rails.env}.log",
                                               :age => 'daily', :size => 12582912, :keep => 9,
                                               :layout => dpattern, :color_scheme => 'default' )
    Logging.logger.root.level = (Rails.env.production? ? :info : :debug )
    Logging.logger.root.appenders = (Rails.env.test? ? arolling : [astdout, arolling] )

    Rails.logger = Logging.logger['SKN']
    ActiveRecord::Base.logger = Rails.logger
    config.logger = Rails.logger

    Rails.logger.info "Rails_Config loaded :#{Rails.env}"
  end
end
