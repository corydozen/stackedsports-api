namespace :twitter do
  desc 'Update all athlete profiles to latest data'
  task update_athlete_profiles: :environment do
    start_time = Time.now
    users = User.all.to_a.delete_if { |u| !u.social_accounts.primary.twitter.first.present? }
    coaches = []
    users.each do |user|
      coaches.push(coach = Coach.new(
        id: user.id,
        email: user.email,
        token: user.social_accounts.primary.twitter.first.oauth_token,
        secret: user.social_accounts.primary.twitter.first.oauth_secret
      ))
    end

    coaches.delete_if { |coach| coach.twitter_client.nil? }

    athletes = Athlete.joins(:twitter_cache_date).where('twitter_cache_dates.profile <= ?', Date.yesterday.end_of_day).or(Athlete.joins(:twitter_cache_date).where(twitter_cache_dates: { profile: nil })).order('twitter_cache_dates.profile')

    max_pool_size = 120
    max_pool_size = 20 if ENV['ENVIRONMENT'] == 'test'
    max_pool_size = 5 if ENV['ENVIRONMENT'] == 'local' || ENV['ENVIRONMENT'] == 'dev'
    # NOTE: Max connections by env
    # prod: 120
    # test: 20
    # local: 5
    pool_size = (max_pool_size * 0.8).to_i # set the pool to 80% of the max

    athletes_to_update = Queue.new
    athletes.each { |a| athletes_to_update.push a.id }

    p "#{coaches.count} available coaches"
    p "#{athletes_to_update.size} athletes to update"

    # Add a stop in the queue so Parallel know when to stop...
    athletes_to_update.push Parallel::Stop
    begin
      Parallel.each(-> { athletes_to_update.shift || Parallel::Stop }, in_threads: pool_size) do |athlete_id|
        # Grab a random coach from the array that is not currently paused
        available_coach = coaches.select { |c| c.end_points[:users] == false }.sample(1)
        # put the athlete back in the queue if there isn't a coach available
        athletes_to_update.unshift(athlete_id) && return unless available_coach
        coach = available_coach.first
        # Grab actual athlete record from id
        athlete = athletes.find { |a| a.id == athlete_id }
        twitter_profile = athlete.twitter_profile if athlete.present? && athlete.twitter_profile.present?
        twitter_profile ||= coach.get_twitter_profile(athlete.twitter_handle, hydrate: true) if athlete.twitter_handle.present?
        coach.update_twitter_profile(twitter_profile) if twitter_profile.present?
        athlete.twitter_cache_date.profile = Time.now
        athlete.twitter_cache_date.save
        p "#{athletes_to_update.size} athletes left to update"
      end
    rescue ThreadError => te
      # p te
      # a thread error could just mean no more work...
    end

    end_time = Time.now

    p "Began Athlete Twitter Profile update at #{start_time}, finished at #{end_time}, total duration: #{TimeDifference.between(start_time, end_time).humanize}"
  end

  desc 'Update all user profiles to latest data'
  task update_user_profiles: :environment do
    start_time = Time.now
    users = User.all.to_a.delete_if { |u| !u.social_accounts.primary.twitter.first.present? }
    coaches = []
    users.each do |user|
      coaches.push(coach = Coach.new(
        id: user.id,
        email: user.email,
        token: user.social_accounts.primary.twitter.first.oauth_token,
        secret: user.social_accounts.primary.twitter.first.oauth_secret
      ))
    end

    coaches.delete_if { |coach| coach.twitter_client.nil? }

    users = User.all

    max_pool_size = 120
    max_pool_size = 20 if ENV['ENVIRONMENT'] == 'test'
    max_pool_size = 5 if ENV['ENVIRONMENT'] == 'local' || ENV['ENVIRONMENT'] == 'dev'
    # NOTE: Max connections by env
    # prod: 120
    # test: 20
    # local: 5
    pool_size = (max_pool_size * 0.8).to_i # set the pool to 80% of the max

    users_to_update = Queue.new
    users.each { |u| users_to_update.push u.id }

    p "#{coaches.count} available coaches"
    p "#{users_to_update.size} users to update"

    # Add a stop in the queue so Parallel know when to stop...
    users_to_update.push Parallel::Stop
    begin
      Parallel.each(-> { users_to_update.shift || Parallel::Stop }, in_threads: pool_size) do |user_id|
        # Grab a random coach from the array that is not currently paused
        available_coach = coaches.select { |c| c.end_points[:users] == false }.sample(1)
        # put the athlete back in the queue if there isn't a coach available
        users_to_update.unshift(user_id) && return unless available_coach
        coach = available_coach.first
        # Grab actual athlete record from id
        user = users.find { |u| u.id == user_id }
        twitter_profiles = user.twitter_profiles if user.present? && user.twitter_profiles.present?
        twitter_profiles.each { |twitter_profile| coach.update_twitter_profile(twitter_profile) } if twitter_profiles.present?
        p "#{users_to_update.size} users left to update"
      end
    rescue ThreadError => te
      # p te
      # a thread error could just mean no more work...
    end

    end_time = Time.now

    p "Began User Twitter Profile update at #{start_time}, finished at #{end_time}, total duration: #{TimeDifference.between(start_time, end_time).humanize}"
  end

  desc 'Update all twitter profiles with missing info to latest data'
  task update_empty_profiles: :environment do
    # profiles = TwitterProfile.where.not(twitter_id: nil).order()
  end

  desc 'Flag questionable content for all records'
  task flag_questionable_content_all_records: :environment do
    start_time = Time.now
    Tweet.where(is_questionable: false).find_in_batches(batch_size: 10_000).with_index do |tweets, batch|
      p "Processing tweets ##{batch}"
      Tweet.transaction do
        tweets.each do |tweet|
          tweet.update_attribute(:is_questionable, true) if Obscenity.profane?(tweet.text)
        end
      end
    end
    end_time = Time.now

    p "Began flagging questionable content at #{start_time}, finished at #{end_time}, total duration: #{TimeDifference.between(start_time, end_time).humanize}"
  end

  desc 'Flag questionable content for content from the last day'
  task flag_questionable_content: :environment do
    start_time = Time.now
    Tweet.where(is_questionable: false, created_at: Date.yesterday.beginning_of_day..Time.now).find_in_batches(batch_size: 10_000).with_index do |tweets, batch|
      p "Processing tweets ##{batch}"
      Tweet.transaction do
        tweets.each do |tweet|
          tweet.update_attribute(:is_questionable, true) if Obscenity.profane?(tweet.text)
        end
      end
    end
    end_time = Time.now

    p "Began flagging questionable content at #{start_time}, finished at #{end_time}, total duration: #{TimeDifference.between(start_time, end_time).humanize}"
  end

  desc 'Flag offers & commits'
  task flag_offers_commits: :environment do
    start_time = Time.now
    oc_settings = CoEmailSetting.first

    offer_keywords = oc_settings.offer_keywords.split(',')
    commit_keywords = oc_settings.commit_keywords.split(',')
    Tweet.where(is_commit: false).or(Tweet.where(is_offer: false)).find_in_batches(batch_size: 10_000).with_index do |tweets, batch|
      p "Processing tweets ##{batch}"
      Tweet.transaction do
        tweets.each do |tweet|
          tweet.update_attribute(:is_offer, true) if offer_keywords.any? { |keyword| tweet.text.downcase.include?(keyword.downcase) }
          tweet.update_attribute(:is_commit, true) if commit_keywords.any? { |keyword| tweet.text.downcase.include?(keyword.downcase) }
        end
      end
    end
    end_time = Time.now

    p "Began flagging commit/offers at #{start_time}, finished at #{end_time}, total duration: #{TimeDifference.between(start_time, end_time).humanize}"
  end
end
