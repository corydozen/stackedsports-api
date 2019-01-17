rails db:migrate;
# 1. Clear retry set
Sidekiq::RetrySet.new.clear
# 2. Clear scheduled jobs
Sidekiq::ScheduledSet.new.clear
# Reset scheduler queue
rake simple_scheduler:reset;
# rake create_message_worker;
