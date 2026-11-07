require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module KeyHarbourEe
  class Application < Rails::Application
    config.load_defaults 8.1
    config.after_initialize do
      ActiveRecord::Encryption.config.encrypt_fixtures = true
    end
    config.i18n.available_locales = %i[en fr]
    config.i18n.default_locale = :fr
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.encoding = "utf-8"
    config.autoload_lib(ignore: %w[assets tasks])
    config.time_zone = "Central Time (US & Canada)"
    config.solid_queue.connects_to = { database: { writing: :queue } }
    config.fixtures_paths = [ Rails.root.join('spec', 'fixtures') ]
    config.active_record.encryption.encrypt_fixtures = true
  end
end
