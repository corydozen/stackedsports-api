require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module StackedSports
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: :any
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # config.middleware.delete ActionDispatch::Session::CookieStore

    config.active_job.queue_adapter = :sidekiq

    config.paperclip_defaults = {
      use_timestamp: false,
      storage: :s3,
      s3_host_name: "s3.#{ENV.fetch('AWS_REGION')}.amazonaws.com",
      s3_protocol: :https,
      s3_storage_class: :REDUCED_REDUNDANCY,
      s3_region: ENV.fetch('AWS_REGION'),
      bucket: ENV.fetch('S3_BUCKET_NAME'),
      url: ':s3_domain_url',
      path: '/:class/:attachment/:id_partition/:style/:filename',
      preserve_files: true,
      s3_credentials: {
        bucket: ENV.fetch('S3_BUCKET_NAME'),
        access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
        secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
        s3_region: ENV.fetch('AWS_REGION')

      }
    }

    config.eager_load_paths += ["#{config.root}/app/classes"]
  end
end
