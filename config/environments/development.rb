# frozen_string_literal: true

Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = true
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true
  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :redis_cache_store, { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/" }
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.public_file_server.enabled = true
  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  config.active_storage.queue = :active_storage_analyzer

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.webpacker.check_yarn_integrity = false

  Rails.application.routes.default_url_options[:host] = "localhost:3000"

  config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: "localhost:3000" }

  if File.file?('/.dockerenv')
    host_ip = `/sbin/ip route|awk '/default/ { print $3 }'`.strip
    config.web_console.whitelisted_ips << host_ip

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: 'mailcatcher',
      port: 1025
    }
  end

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.after_initialize do
    # Bullet Configuration
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.rails_logger = true
  end
  config.action_controller.asset_host = 'http://localhost:3000'

  config.action_mailer.asset_host = 'http://localhost:3000'
end
