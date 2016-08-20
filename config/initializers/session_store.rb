# Be sure to restart your server when you modify this file.
# Ref: https://github.com/redis-store/redis-store/wiki/Frameworks-Configuration

Rails.application.config.session_store :cookie_store,key: '_SknServices_session',domain: :all
                                       # tld_length: 1
                                       # expires_in: 120.minutes
