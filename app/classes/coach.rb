require 'twitter_profile'
class Coach
  # include Celluloid
  # include Concurrent::Async
  attr_accessor :id, :email, :token, :secret, :searches, :twitter_client, :end_points

  def initialize(id:, email:, token:, secret:, searches: 0)
    @id = id
    @email = email
    @token = token
    @secret = secret
    @searches = searches
    # @is_paused = is_paused
    # @paused_for = 0
    @end_points = {
      self: false,
      users: false,
      tweets: false,
      followers: false,
      friends: false,
      favorites: false
    }
    @twitter_client = create_twitter_client_for_coach(token, secret)
  end

  def pause(duration, end_point)
    # @is_paused = true
    @end_points[end_point] = true
    rate_limit_thread = Thread.new do
      Thread.current['counter'] = duration + 1

      (duration + 1).times do
        sleep 1
        Thread.current['counter'] -= 1
        # @paused_for = Thread.current['counter'];
        puts "#{@id} - #{@email} access to #{end_point} is paused for #{Thread.current['counter']} seconds"
      end
    end
    #   @paused_for = RateLimitHelper.wait_progress(duration + 1, "#{@id} - #{@email}")
    rate_limit_thread.join
    unpause(end_point)
  end

  def unpause(end_point)
    # @is_paused = false
    @end_points[end_point] = false
  end

  def get_twitter_profile(twitter_handle_or_id, hydrate: false)
    p "Hydrate: #{hydrate}"
    # hydrate determines if a lookup to twitter should be perform, if the user did not already exist
    # get (or create) the twitter profile
    look_up_value = (twitter_handle_or_id.is_a?(Numeric) ? 'twitter_id' : 'screen_name').to_sym
    TwitterProfile.find_or_create_by(look_up_value => twitter_handle_or_id) do |tp|
      begin
        if hydrate
          twitter_user = twitter_client.user(twitter_handle_or_id)
          tp.twitter_id = twitter_user.id
          tp.id_str = twitter_user.id.to_s
          tp.name = twitter_user.name
          tp.screen_name = twitter_user.screen_name
          tp.location = twitter_user.location
          tp.description = twitter_user.description
          tp.url = twitter_user.url
          tp.protected = twitter_user.protected?
          tp.followers_count = twitter_user.followers_count
          tp.friends_count = twitter_user.friends_count
          tp.listed_count = twitter_user.listed_count
          tp.favorites_count = twitter_user.favorites_count
          tp.geo_enabled = twitter_user.geo_enabled?
          tp.verified = twitter_user.verified?
          tp.statuses_count = twitter_user.statuses_count
          tp.lang = twitter_user.lang
          tp.profile_background_color = twitter_user.profile_background_color
          tp.profile_background_image_url = twitter_user.profile_background_image_url
          tp.profile_background_image_url_https = twitter_user.profile_background_image_url_https
          tp.profile_background_tile = twitter_user.profile_background_tile?
          tp.profile_image_url = twitter_user.profile_image_url
          tp.profile_image_url_https = twitter_user.profile_image_url_https
          tp.profile_banner_url = twitter_user.profile_banner_url
          tp.profile_link_color = twitter_user.profile_link_color
          tp.profile_sidebar_border_color = twitter_user.profile_sidebar_border_color
          tp.profile_sidebar_fill_color = twitter_user.profile_sidebar_fill_color
          tp.profile_text_color = twitter_user.profile_text_color
          tp.profile_use_background_image = twitter_user.profile_use_background_image?
          tp.default_profile = twitter_user.default_profile?
          tp.default_profile_image = twitter_user.default_profile_image?
        end
      rescue Twitter::Error::Unauthorized => exc
        p exc
        nil
        # Could be an expired token, but otherwise not sure what happened that we got here and got this error...
      rescue Twitter::Error::TooManyRequests => rate_limited
        pause(rate_limited.rate_limit.reset_in, :users)
      rescue Twitter::Error::Forbidden => suspended
        p "Coach #{@id} - #{@email} has been suspended"
        nil
      rescue Twitter::Error::NotFound => user_not_found
        p "User not found with handle or ID: #{twitter_handle_or_id}"
        nil
      rescue ActiveRecord::ConnectionTimeoutError => no_db
        sleep 5
        retry
      end
    end
  end

  def update_twitter_profile(twitter_profile)
    return unless twitter_profile.present? && twitter_profile.twitter_id.present?

    twitter_user = twitter_client.user(twitter_profile.twitter_id)

    tp = twitter_profile

    tp.id_str = twitter_user.id.to_s if tp.id_str != twitter_user.id.to_s
    tp.name = twitter_user.name if tp.name != twitter_user.name
    tp.screen_name = twitter_user.screen_name.downcase if !tp.screen_name.present? || !tp.screen_name.casecmp(twitter_user.screen_name).zero?
    tp.location = twitter_user.location if tp.location != twitter_user.location
    tp.description = twitter_user.description if tp.description != twitter_user.description
    tp.url = twitter_user.url if tp.url != twitter_user.url
    tp.protected = twitter_user.protected? if tp.protected != twitter_user.protected?
    tp.verified = twitter_user.verified? if tp.verified != twitter_user.verified?
    tp.profile_image_url = twitter_user.profile_image_url if tp.profile_image_url != twitter_user.profile_image_url
    tp.profile_image_url_https = twitter_user.profile_image_url_https if tp.profile_image_url_https != twitter_user.profile_image_url_https
    if tp.changed?
      p "Updating #{tp.screen_name} with ID: #{tp.id}, the following fields were changed: #{tp.changes}"
      tp.save!
    end
  rescue Twitter::Error::Unauthorized => exc
    p exc
    nil
    # Could be an expired token, but otherwise not sure what happened that we got here and got this error...
  rescue ActiveRecord::RecordInvalid => bad_record
    p bad_record
    nil
  rescue Twitter::Error::TooManyRequests => rate_limited
    pause(rate_limited.rate_limit.reset_in, :users)
  rescue Twitter::Error::Forbidden => suspended
    p "Coach #{@id} - #{@email} has been suspended"
    nil
  rescue Twitter::Error::NotFound => user_not_found
    p "User not found with handle: #{twitter_profile.screen_name}"
    nil
  rescue ActiveRecord::ConnectionTimeoutError => no_db
    sleep 5
    retry
  end

  def get_tweets(athlete)
    return unless athlete.twitter_handle.present?

    # Get twitter data for athlete
    begin
      twitter_profile = get_twitter_profile(athlete.twitter_handle, hydrate: true)

      return unless twitter_profile.present?

      p "Coach #{@id} - #{@email} getting tweets for athlete: #{athlete.first_name} #{athlete.last_name} - @#{athlete.twitter_handle}"
      since_id = twitter_profile.tweets.maximum(:id) if twitter_profile.tweets.present?
      tweets = get_all_tweets(athlete.twitter_handle, since_id)

      # Increment searches
      @searches += 1
      tweets_to_save = []
      if tweets.present?
        tweets.each do |tweet|
          # Store the twitter data
          # p "Storing Tweet ID: #{tweet.id}"
          hashtags = ''
          tweet.hashtags.each { |ht| hashtags += "#{ht.text}," } if tweet.hashtags.present?
          hashtags = hashtags.to_s.chomp(',')
          urls = []
          tweet.urls.each { |url| urls << url.attrs } if tweet.urls.present?
          users = {}
          tweet.user_mentions.each { |um| users[um.id] = um.screen_name } if tweet.user_mentions.present?
          media = []
          tweet.media.each { |m| media << m.attrs } if tweet.media.present?
          symbols = ''
          symbols = tweet.symbols.each { |symbol| symbols += "#{symbol.text}," } if tweet.symbols.present?
          symbols = symbols.to_s.chomp(',')

          tweets_to_save << Tweet.new(
            id: tweet.id,
            id_str: tweet.id.to_s,
            created_at: tweet.created_at,
            updated_at: tweet.created_at,
            text: tweet.text,
            truncated: tweet.truncated?,
            source: (tweet.source.present? ? tweet.source : nil),
            in_reply_to_status_id: (tweet.in_reply_to_status_id.present? ? tweet.in_reply_to_status_id : nil),
            in_reply_to_status_id_str: tweet.in_reply_to_status_id.to_s,
            in_reply_to_user_id: (tweet.in_reply_to_user_id.present? ? tweet.in_reply_to_user_id : nil),
            in_reply_to_user_id_str: tweet.in_reply_to_user_id.to_s,
            in_reply_to_screen_name: (tweet.in_reply_to_screen_name.present? ? tweet.in_reply_to_screen_name : nil),
            # quoted_status_id: tweet.quoted_status_id,
            # quoted_status_id_str: tweet.quoted_status_id.to_s,
            is_quote_status: tweet.quoted_status?,
            retweeted_status: (tweet.retweeted_status.present? ? tweet.retweeted_status : nil),
            quote_count: (tweet.quote_count.present? ? tweet.quote_count : nil),
            retweet_count: tweet.retweet_count,
            favorite_count: tweet.favorite_count,
            possibly_sensitive: tweet.possibly_sensitive?,
            filter_level: (tweet.filter_level.present? ? tweet.filter_level : nil),
            hashtags: (hashtags.present? ? hashtags : nil),
            urls: (urls.present? ? urls.to_s : nil),
            user_mentions: users.to_s,
            media: media.to_s,
            symbols: symbols,
            # polls = tweet.polls.to_s if tweet.polls.present?
            lang: tweet.lang,
            twitter_profile_id: twitter_profile.id
          )
        end
      end
      p "Saving #{tweets_to_save.count} tweets for athlete: #{athlete.first_name} #{athlete.last_name}"
      Tweet.import(tweets_to_save, on_duplicate_key_ignore: true) if tweets_to_save.present?
    rescue Twitter::Error::TooManyRequests => rate_limited
      pause(rate_limited.rate_limit.reset_in, :tweets)
    rescue Twitter::Error::Unauthorized => exc
      p exc
      nil
      # Could be an expired token, but otherwise not sure what happened that we got here and got this error...
    rescue ActiveRecord::ConnectionTimeoutError => no_db
      sleep 5
      retry
    end
  end

  def get_favorites(athlete)
    return unless athlete.twitter_handle.present?

    # Get twitter data for athlete
    begin
      twitter_profile = get_twitter_profile(athlete.twitter_handle, hydrate: true)

      return unless twitter_profile.present?

      p "Coach #{@id} - #{@email} getting favorites for athlete: #{athlete.first_name} #{athlete.last_name} - @#{athlete.twitter_handle}"
      since_id = twitter_profile.favorites.maximum(:tweet_id) if twitter_profile.favorites.present?
      tweets = get_all_tweets(athlete.twitter_handle, since_id, true)

      # Increment searches
      @searches += 1
      tweets_to_save = []
      if tweets.present?
        tweets.each do |tweet|
          # Store the twitter data
          # p "Storing Tweet ID: #{tweet.id}"
          hashtags = ''
          tweet.hashtags.each { |ht| hashtags += "#{ht.text}," } if tweet.hashtags.present?
          hashtags = hashtags.to_s.chomp(',')
          urls = []
          tweet.urls.each { |url| urls << url.attrs } if tweet.urls.present?
          users = {}
          tweet.user_mentions.each { |um| users[um.id] = um.screen_name } if tweet.user_mentions.present?
          media = []
          tweet.media.each { |m| media << m.attrs } if tweet.media.present?
          symbols = ''
          symbols = tweet.symbols.each { |symbol| symbols += "#{symbol.text}," } if tweet.symbols.present?
          symbols = symbols.to_s.chomp(',')

          tweets_to_save << Tweet.new(
            id: tweet.id,
            id_str: tweet.id.to_s,
            created_at: tweet.created_at,
            updated_at: tweet.created_at,
            text: tweet.text,
            truncated: tweet.truncated?,
            source: tweet.source,
            in_reply_to_status_id: tweet.in_reply_to_status_id,
            in_reply_to_status_id_str: tweet.in_reply_to_status_id.to_s,
            in_reply_to_user_id: tweet.in_reply_to_user_id,
            in_reply_to_user_id_str: tweet.in_reply_to_user_id.to_s,
            in_reply_to_screen_name: tweet.in_reply_to_screen_name,
            # quoted_status_id: tweet.quoted_status_id,
            # quoted_status_id_str: tweet.quoted_status_id.to_s,
            is_quote_status: tweet.quoted_status?,
            retweeted_status: tweet.retweeted_status,
            quote_count: tweet.quote_count,
            retweet_count: tweet.retweet_count,
            favorite_count: tweet.favorite_count,
            possibly_sensitive: tweet.possibly_sensitive?,
            filter_level: tweet.filter_level,
            hashtags: hashtags,
            urls: urls.to_s,
            user_mentions: users.to_s,
            media: media.to_s,
            symbols: symbols,
            # polls = tweet.polls.to_s if tweet.polls.present?
            lang: tweet.lang,
            twitter_profile_id: twitter_profile.id
          )
        end
      end
      p "Saving #{tweets_to_save.count} tweets for athlete: #{athlete.first_name} #{athlete.last_name}"
      Tweet.import(tweets_to_save, on_duplicate_key_ignore: true) if tweets_to_save.present?

      # TODO: Create a favorites table with twitter_profile_id and tweet_id
      favorites_to_save = []
      tweets_to_save.map { |tweet| favorites_to_save << Favorite.new(twitter_profile_id: tweet.twitter_profile_id, tweet_id: tweet.id) }
      Favorite.import(favorites_to_save, on_duplicate_key_ignore: true) if favorites_to_save.present?
    rescue Twitter::Error::TooManyRequests => rate_limited
      pause(rate_limited.rate_limit.reset_in, :tweets)
    end
  end

  def get_followers(athlete)
    return unless athlete.twitter_handle.present?

    twitter_profile = get_twitter_profile(athlete.twitter_handle, hydrate: true)
    return unless twitter_profile.present?

    p "Coach #{@id} - #{@email} getting followers for athlete: #{athlete.first_name} #{athlete.last_name} - @#{athlete.twitter_handle}"
    current_follower_ids = []
    current_followers = Follower.where(twitter_profile_id: twitter_profile.id)
    current_followers.map { |cf| current_follower_ids << cf.follower_id } if current_followers.present?

    followers = get_all_follower_ids(athlete.twitter_handle)

    followers_to_save = []
    if followers.present?
      followers.each do |follower|
        follower_profile = get_twitter_profile(follower, hydrate: false)

        followers_to_save << Follower.new(
          twitter_profile_id: twitter_profile.id,
          follower_id: follower_profile.id
        )
      end
    end

    # TODO: log a follow / unfollow event!!!

    p "Saving #{followers_to_save.count} followers for athlete: #{athlete.first_name} #{athlete.last_name}"
    Follower.import(followers_to_save, on_duplicate_key_ignore: true) if followers_to_save.present?

    # NOTE: If we have current_followers then compare them to what we just saved
    if current_follower_ids.present?
      # NOTE: pull followers now that we've save to get a delta
      latest_follower_ids = []
      current_followers = Follower.where(twitter_profile_id: twitter_profile.id)
      current_followers.map { |cf| latest_follower_ids << cf.follower_id } if current_followers.present?

      # NOTE: remove latest follower ids from current follow ids
      unfollowed_ids = current_follower_ids - latest_follower_ids

      if unfollowed_ids.present?
        unfollowed_ids.each do |unfollower|
          # NOTE: if there were any unfollowed_ids then loop over them and update the unfollow_date
          Follower.where(twitter_profile_id: twitter_profile.id, follower_id: unfollower).update(unfollow_date: Time.now)
        end
      end
    end
  end

  private

  def create_twitter_client_for_coach(token, secret)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['RS_TWITTER_API_KEY']
      config.consumer_secret     = ENV['RS_TWITTER_API_SECRET']
      config.access_token        = token
      config.access_token_secret = secret
    end
    # NOTE: This call is to check the validity of the client
    # client.home_timeline
    client
  rescue Twitter::Error::TooManyRequests => rate_limited
    p rate_limited
    pause(rate_limited.rate_limit.reset_in, :self)
  rescue Twitter::Error::Unauthorized => exc
    p exc
    nil
    # Could be an expired token, but otherwise not sure what happened that we got here and got this error...
  rescue ActiveRecord::ConnectionTimeoutError => no_db
    p no_db
    sleep 5
    retry
  rescue StandardError => exc
    p exc
    nil
  end

  def collect_tweets_with_max_id(collection = [], max_id = nil, &block)
    tweets = yield(max_id)
    return collection unless tweets.present?

    collection += tweets
    tweets.empty? ? collection.flatten : collect_tweets_with_max_id(collection, tweets.last.id - 1, &block)
  end

  def get_all_tweets(handle, since_id = nil, favorites = false)
    collect_tweets_with_max_id do |max_id|
      begin
        options = { count: 200, include_rts: true, exclude_replies: false, trim_user: true }
        options[:max_id] = max_id if max_id.present?
        options[:since_id] = since_id if since_id.present?
        if favorites
          @twitter_client.favorites(handle, options)
        else
          @twitter_client.user_timeline(handle, options)
        end
      rescue ActiveRecord::ConnectionTimeoutError => no_db
        sleep 5
        retry
      rescue Twitter::Error::ServiceUnavailable => over_capacity
        # I think we broke the twitter, we should let it rest a little while
        pause(60, :tweets)
      rescue Twitter::Error::TooManyRequests => rate_limited
        if favorites
          pause(rate_limited.rate_limit.reset_in, :favorites)
        else
          pause(rate_limited.rate_limit.reset_in, :tweets)
        end
      rescue Twitter::Error::NotFound => tweet_not_found
        # Moving on...
        p tweet_not_found
        nil
      rescue Twitter::Error::Unauthorized => exc
        p exc
        nil
        # Could be an expired token, but otherwise not sure what happened that we got here and got this error...
      end
    end
  end

  def with_rate_limit_retry(&_block)
    yield
  rescue ActiveRecord::ConnectionTimeoutError => no_db
    sleep 5
    retry
  rescue Twitter::Error::ServiceUnavailable => over_capacity
    # I think we broke the twitter, we should let it rest a little while
    pause(60, :followers)
    retry
  rescue Twitter::Error::TooManyRequests => error
    pause(error.rate_limit.reset_in, :followers)
    retry
  rescue Twitter::Error::NotFound => not_found
    # Moving on
  rescue Twitter::Error::InternalServerError => error
    pause(60, :followers)
    retry
  end

  def to_a_with_rate_limit_retry(cursor)
    return unless cursor

    result = []

    # logger.info 'started cursor fetch'

    iterator = cursor.each

    loop do
      begin
        item = with_rate_limit_retry { iterator.next }
        result << item
      rescue StopIteration
        break
      end

      # logger.info "..#{result.count} items fetched" if result.count % 1000 == 0
    end

    # logger.info "ended cursor fetch, #{result.count} items fetched total"

    result
  end

  def get_all_follower_ids(handle)
    follower_ids_cursor = with_rate_limit_retry { @twitter_client.follower_ids(handle) }
    follower_ids = to_a_with_rate_limit_retry(follower_ids_cursor)
  end
end
