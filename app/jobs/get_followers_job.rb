class GetFollowersJob < ApplicationJob
  queue_as :twitter

  def perform(_scheduled_time)
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

    max_pool_size = 5 if ENV['ENVIRONMENT'] == 'local' || ENV['ENVIRONMENT'] == 'dev'
    max_pool_size ||= 20 if ENV['ENVIRONMENT'] == 'test'
    max_pool_size ||= 120

    # NOTE: Max connections by env
    # prod: 120
    # test: 20
    # local: 5
    pool_size = (max_pool_size * 0.3).to_i # set the pool to 30% of the max

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
end
