Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'], size: ENV['SIDEKIQ_CONCURRENCY'].to_i + 2 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'], size: 1 }
end
