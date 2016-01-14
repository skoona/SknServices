require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'java'

module AuthService
  class Application < Rails::Application

    Config::Integration::Rails::Railtie.preload

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += Dir["#{Rails.root}/lib/**/"]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = Settings.Packaging.time_zone

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.active_record.schema_format = :ruby

    # config.log_formatter = ActiveSupport::TaggedLogging::Formatter
    config.log_tags = [Proc.new {Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')}, Proc.new {AuthService::Application.config.log_level.upcase}]
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new("#{Rails.root}/log/#{Rails.env}.log", 'daily'))
  end
end
