# require File.dirname(__FILE__) + '../classes/coach.rb'
# require Rails.root + '/lib/classes/coach.rb'

namespace :athletes do
  desc 'Get latest tweets for all athletes'
  task get_tweets: :environment do
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

    athletes = Athlete.joins(:twitter_cache_date).where('twitter_cache_dates.tweets <= ?', Date.yesterday.end_of_day).or(Athlete.joins(:twitter_cache_date).where(twitter_cache_dates: { tweets: nil })).order('twitter_cache_dates.tweets')

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
    # For logging...
    total_athletes = athletes_to_update.size

    p "#{coaches.count} available coaches"
    p "#{athletes_to_update.size} athletes to update"

    # Add a stop in the queue so Parallel know when to stop...
    athletes_to_update.push Parallel::Stop
    begin
      Parallel.each(-> { athletes_to_update.shift || Parallel::Stop }, in_threads: pool_size) do |athlete_id|
        # Grab a random coach from the array that is not currently paused
        available_coach = coaches.select { |c| c.end_points[:tweets] == false }.sample(1)
        # put the athlete back in the queue if there isn't a coach available
        athletes_to_update.unshift(athlete_id) && return unless available_coach
        coach = available_coach.first
        # Grab actual athlete record from id
        athlete = athletes.find { |a| a.id == athlete_id }
        coach.get_tweets(athlete)
        athlete.twitter_cache_date.tweets = Time.now
        athlete.twitter_cache_date.save
        p "#{athletes_to_update.size} athletes left to update"
      end
    rescue ThreadError => te
      # p te
      # a thread error could just mean no more work...
    end

    end_time = Time.now

    p "Began Tweet retrieval at #{start_time}, finished at #{end_time}, total duration: #{TimeDifference.between(start_time, end_time).humanize} to process #{total_athletes} athletes"
  end

  desc 'Get followers for all athletes'
  task get_followers: :environment do
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

    athletes = Athlete.joins(:twitter_cache_date).where('twitter_cache_dates.followers <= ?', Date.yesterday.end_of_day).or(Athlete.joins(:twitter_cache_date).where(twitter_cache_dates: { followers: nil })).order('twitter_cache_dates.followers')

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
        available_coach = coaches.select { |c| c.end_points[:followers] == false }.sample(1)
        # put the athlete back in the queue if there isn't a coach available
        athletes_to_update.unshift(athlete_id) && return unless available_coach
        coach = available_coach.first
        # Grab actual athlete record from id
        athlete = athletes.find { |a| a.id == athlete_id }
        coach.get_followers(athlete)
        athlete.twitter_cache_date.followers = Time.now
        athlete.twitter_cache_date.save
        p "#{athletes_to_update.size} athletes left to update"
      end
    rescue ThreadError => te
      # p te
      # a thread error could just mean no more work...
    end

    end_time = Time.now

    p "Began Follower retrieval at #{start_time}, finished at #{end_time}, total duration: #{TimeDifference.between(start_time, end_time).humanize}"
  end

  desc 'Import new athletes from Recruit Suite'
  task update_temp: :environment do
    rsaths = RsAthlete.all
    rsaths_array = rsaths.to_a.delete_if { |a| a[:twitterProfile].nil? || a[:twitterProfile] == '' }

    athlete_ocurrences = rsaths_array.group_by { |a| a[:twitterProfile]['screenName'] }.map { |k, v| [k, v.size] }.to_h
    p "#{rsaths.count} RS Athletes"
    rsaths.each do |rsath|
      next unless rsath.twitterProfile.present? && rsath.twitterProfile['screenName'].present?

      ta = TempAthlete.where('lower(twitter_handle) = ?', rsath.twitterProfile['screenName'].downcase).first_or_create(twitter_handle: rsath.twitterProfile['screenName'].downcase)
      next unless ta.present?

      # So if we got this far, we have either found or created a temp athlete, so now we need to check if his data needs to be updated
      ta.grad_year = rsath.grad_year if rsath.grad_year.present? && !ta.grad_year.present?
      ta.positions = rsath.positions if rsath.positions.present? && !ta.positions.present?
      name_array = rsath.name.split(' ') if rsath.name.present?
      if name_array.present?
        # p "Name Array info: #{name_array}"
        ta.first_name = name_array[0] unless ta.first_name.present?
        # Shifting array to get the rest of name as last name
        name_array.shift
        ta.last_name = name_array.join(' ') if !ta.last_name.present? && name_array.present? # this will be empty if there were no spaces in the name
      end
      # ta.address = rsath.address if rsath.address.present? && !ta.address.present?
      # ta.state = rsath.state if rsath.state.present? && !ta.state.present?
      # ta.city = rsath.city if rsath.city.present? && !ta.city.present?
      # ta.zip_code = rsath.zip_code if rsath.zip_code.present? && !ta.zip_code.present?
      ta.mobile = rsath.phone if rsath.phone.present? && !ta.mobile.present?
      ta.email = rsath.email if rsath.email.present? && !ta.email.present?
      ta.hs_name = rsath.high_school if rsath.high_school.present? && !ta.hs_name.present?
      # ta.hs_state = rsath.hs_state if rsath.hs_state.present? && !ta.hs_state.present?
      ta.priority = athlete_ocurrences[ta.twitter_handle] if athlete_ocurrences[ta.twitter_handle].present? && ta.priority != athlete_ocurrences[ta.twitter_handle]
      next unless ta.changed?

      # The model has been updated so print some output and save the record
      p "Updating #{ta.first_name} #{ta.last_name} - @#{ta.twitter_handle} with ID: #{ta.id}, the following fields were changed: #{ta.changes}"
      ta.save!
    end
  end

  desc 'Import athletes from temp'
  task import_from_temp: :environment do
    temp_athletes = TempAthlete.where.not(twitter_handle: nil).where(ignore: false)
    p "#{temp_athletes.count} TempAthletes"
    temp_athletes.each do |temp_athlete|
      begin
        twitter_profile = TwitterProfile.find_or_create_by(screen_name: temp_athlete.twitter_handle.downcase)
        # twitter_profile ||= TwitterProfile.new(screen_name: temp_athlete.twitter_handle.downcase).save!
        # p twitter_profile

        # TwitterProfile.where('lower(screen_name) = ?', temp_athlete.twitter_handle.downcase).first_or_create(screen_name: temp_athlete.twitter_handle.downcase)
      rescue StandardError => exc
        p exc
      end

      begin
        athlete = Athlete.find_or_create_by(
          first_name: (temp_athlete.first_name || (twitter_profile.name.present? ? twitter_profile.name.split(' ').first : nil)),
          last_name: (temp_athlete.last_name || (twitter_profile.name.present? ? twitter_profile.name.split(' ').second : nil)),
          twitter_profile_id: twitter_profile.id
        ) do |a|
          a.phone = temp_athlete.mobile
          a.email = temp_athlete.email
          a.nick_name = temp_athlete.first_name
          a.graduation_year = Date.parse("#{temp_athlete.grad_year}-05-01")
          a.grad_year = temp_athlete.grad_year
          a.high_school = temp_athlete.hs_name
          a.state = temp_athlete.hs_state
          # a.coach_name = temp_athlete.
          # a.mothers_name = temp_athlete.
          # a.fathers_name = temp_athlete.
          a.position = temp_athlete.positions
          a.created_at = Time.now
          a.updated_at = Time.now
        end
        athlete.save!
      rescue StandardError => exc
        p exc
      end
      # p athlete
    end
  end

  desc 'Update Temp Commit Offer table'
  task get_offers_commits: :environment do
    start_time = Time.now
    # Get all athletes in highest priority order
    athletes = Athlete.all

    athletes.each do |athlete|
      p "Checking Commits & Offers for #{athlete.first_name} #{athlete.last_name}"
      athlete.get_oc_tweets
    end

    end_time = Time.now

    p "Began process at #{start_time}, finished process at #{end_time}, total duration: #{TimeDifference.between(start_time, end_time).humanize}"
  end

  desc 'Create any missing cache dates'
  task create_cache_dates: :environment do
    Athlete.all.each do |athlete|
      TwitterCacheDate.find_or_create_by(athlete_id: athlete.id)
    end
  end
end
