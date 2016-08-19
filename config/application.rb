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

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += Dir["#{Rails.root}/lib/**/"]

    # config.action_view.javascript_expansions[:defaults] = %w(jquery.min jquery_ujs)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = Settings.Packaging.time_zone

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

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
    Rails.logger.info "Rails_Config loaded #{Rails.env}"

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true
    config.active_record.schema_format = :ruby

    # config.middleware.insert_after ActionDispatch::ParamsParser, Rack::Attack
    config.middleware.use Rack::Attack

  end
end
