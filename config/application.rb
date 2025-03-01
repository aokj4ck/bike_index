require_relative "boot"

require "rails"

# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

require "rack/throttle"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bikeindex
  class Application < Rails::Application
    config.redis_default_url = ENV["REDIS_URL"]
    config.redis_cache_url = ENV["REDIS_CACHE_URL"]

    config.load_defaults 6.1

    # Use our custom error pages
    config.exceptions_app = routes

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.time_zone = "Central Time (US & Canada)"

    # Force sql schema use so we get psql extensions
    config.active_record.schema_format = :sql

    # Disable default implicit presence validation for belongs_to relations
    config.active_record.belongs_to_required_by_default = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}").to_s]
    config.i18n.enforce_available_locales = false
    config.i18n.default_locale = :en
    config.i18n.available_locales = %i[en nl nb es]
    config.i18n.fallbacks = {"en-US": :en, "en-GB": :en}

    config.middleware.use Rack::Throttle::Minute,
      max: ENV["MIN_MAX_RATE"].to_i,
      cache: Redis.new(url: config.redis_cache_url),
      key_prefix: :throttle

    # Add middleware to make i18n configuration thread-safe
    config.middleware.use I18n::Middleware

    ActiveSupport::Reloader.to_prepare do
      Doorkeeper::ApplicationsController.layout "doorkeeper"
      Doorkeeper::AuthorizationsController.layout "doorkeeper"
      Doorkeeper::AuthorizedApplicationsController.layout "doorkeeper"
    end

    config.generators do |g|
      g.factory_bot "true"
      g.helper nil
      g.javascripts nil
      g.stylesheets nil
      g.template_engine nil
      g.serializer nil
      g.assets nil
      g.test_framework :rspec, view_specs: false, routing_specs: false, controller_specs: false
      g.system_tests nil
    end
  end
end
