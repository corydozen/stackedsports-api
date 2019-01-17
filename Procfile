web: bundle exec puma -C config/puma.rb
sms_worker: bundle exec sidekiq -C config/sidekiq_sms_messages.yml
twitter_dm_worker: bundle exec sidekiq -C config/sidekiq_dm_messages.yml
twitter_jobs_worker: bundle exec sidekiq -C config/sidekiq_twitter_jobs.yml
worker: bundle exec sidekiq -C config/sidekiq.yml
release: bash bin/heroku_release.sh
