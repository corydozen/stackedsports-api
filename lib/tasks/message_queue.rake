namespace :message_queue do
  desc 'Parse message table for items to be sent'
  task process_twitter: :environment do
    MessageQueueJob.perform_now(Time.now)
  end
end
