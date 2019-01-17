namespace :athlete_reports do
  desc 'Populate reports'
  task populate_report: :environment do
    start_time = Time.now
    p "Began at #{start_time}"
    twitter_platform_id = Platform.twitter.first.id
    sms_platform_id = Platform.sms.first.id
    athletes = Athlete.all
    users = User.all

    dates = Calendar.all

    athletes.each do |athlete|
      tweets = athlete.twitter_profile.tweets
      favorited_tweets = []
      athlete.twitter_profile.favorites.each { |fav| favorited_tweets << fav.tweet }
      users.each do |_user|
        organization = _user.teams.first.organization
        # Move on if the user doesn't have a twitter profile
        if _user.primary_twitter_profile.present?
          # Get the retweets for an athlete of an user
          user_tweets_from_retweets = tweets.where(twitter_profile_id: _user.primary_twitter_profile.first.id) if tweets.present?
          retweet_count_by_day = user_tweets_from_retweets.group_by_day(:created_at).count if user_tweets_from_retweets.present?
          if retweet_count_by_day.present?
            retweet_count_by_day.each do |date, count|
              next if count == 0
              p "Saving athlete: #{athlete.id} retweets of user: #{_user.id} for #{date}"
              rpt = AthleteReportDatum.find_or_create_by(athlete_id: athlete.id, user_id: _user.id, organization_id: organization.id, as_of: date)
              next unless rpt.present?
              next if rpt.retweets == count
              rpt.retweets = count
              rpt.save!
            end
          end

          user_mentions_from_tweets = tweets.where("user_mentions like '%#{_user.primary_twitter_profile.first.screen_name}%'") if tweets.present?
          mention_count_by_day = user_mentions_from_tweets.group_by_day(:created_at).count if user_mentions_from_tweets.present?
          if mention_count_by_day.present?
            mention_count_by_day.each do |date, count|
              next if count == 0
              p "Saving athlete: #{athlete.id} mentions of user: #{_user.id} for #{date}"
              rpt = AthleteReportDatum.find_or_create_by(athlete_id: athlete.id, user_id: _user.id, organization_id: organization.id, as_of: date)
              next unless rpt.present?
              next if rpt.mentions == count
              rpt.mentions = count
              rpt.save!
            end
          end

          if favorited_tweets.present?
            favorites = []
            favorited_tweets.each { |fav_tweet| favorites << fav_tweet if fav_tweet.twitter_profile_id == _user.primary_twitter_profile.first.id }
          end
          favorites_count_by_day = favorites.group_by_day(:created_at).count if favorites.present?
          if favorites_count_by_day.present?
            favorites_count_by_day.each do |date, count|
              next if count == 0
              p "Saving athlete: #{athlete.id} favorites of user: #{_user.id} for #{date}"
              rpt = AthleteReportDatum.find_or_create_by(athlete_id: athlete.id, user_id: _user.id, organization_id: organization.id, as_of: date)
              next unless rpt.present?
              next if rpt.likes == count
              rpt.likes = count
              rpt.save!
            end
          end
        end

        dms = Message.joins(:message_recipients).where(user_id: _user.id, message_recipients: { athlete_id: athlete.id, platform_id: twitter_platform_id, status: 'sent' }).select('message_recipients.*')
        dm_count_by_day = dms.group_by_day(:sent_at).count if dms.present?
        if dm_count_by_day.present?
          dm_count_by_day.each do |date, count|
            next if count == 0
            p "Saving athlete: #{athlete.id} DMs of user: #{_user.id} for #{date}"
            rpt = AthleteReportDatum.find_or_create_by(athlete_id: athlete.id, user_id: _user.id, organization_id: organization.id, as_of: date)
            next unless rpt.present?
            next if rpt.dms == count
            rpt.dms = count
            rpt.save!
          end
        end

        sms = Message.joins(:message_recipients).where(user_id: _user.id, message_recipients: { athlete_id: athlete.id, platform_id: sms_platform_id, status: 'sent' }).select('message_recipients.*')
        sms_count_by_day = sms.group_by_day(:sent_at).count if sms.present?
        next unless sms_count_by_day.present?
        sms_count_by_day.each do |date, count|
          next if count == 0
          p "Saving athlete: #{athlete.id} SMS of user: #{_user.id} for #{date}"
          rpt = AthleteReportDatum.find_or_create_by(athlete_id: athlete.id, user_id: _user.id, organization_id: organization.id, as_of: date)
          next unless rpt.present?
          next if rpt.sms == count
          rpt.sms = count
          rpt.save!
        end
      end
    end
    end_time = Time.now
    p "Began Athlete Report Populate at #{start_time}, finished at #{end_time}, total duration: #{TimeDifference.between(start_time, end_time).humanize}"
  end

  desc 'Populate Analysis'
  task populate_analysis: :environment do
    start_time = Time.now
    p "Began at #{start_time}"
    athletes = Athlete.all

    athletes.each do |athlete|
      all_tweets = athlete.twitter_profile.tweets
      original_tweets = all_tweets.where("text not like 'RT @%'")
      retweets = all_tweets.where("text like 'RT @%'")

      tweet_count_by_day = original_tweets.group_by_day(:created_at, series: false).count if original_tweets.present?
      if tweet_count_by_day.present?
        tweet_count_by_day.each do |date, count|
          p "Saving tweet counts for athlete: #{athlete.id} on #{date}"
          ara = AthleteActivityAnalysis.find_or_create_by(athlete_id: athlete.id, as_of: date, dow: date.strftime('%A'))
          next unless ara.present?
          next if ara.tweets == count
          ara.tweets = count
          ara.save!
        end
      end

      retweet_count_by_day = retweets.group_by_day(:created_at, series: false).count if retweets.present?
      if retweet_count_by_day.present?
        retweet_count_by_day.each do |date, count|
          p "Saving retweet counts for athlete: #{athlete.id} on #{date}"
          ara = AthleteActivityAnalysis.find_or_create_by(athlete_id: athlete.id, as_of: date, dow: date.strftime('%A'))
          next unless ara.present?
          next if ara.retweets == count
          ara.retweets = count
          ara.save!
        end
      end

      favorited_tweets = []
      athlete.twitter_profile.favorites.each { |fav| favorited_tweets << fav.tweet }
      # favorites_count_by_day = favorited_tweets.group_by_day(:created_at).count if favorited_tweets.present?
      favorites_count_by_day = Hash[favorited_tweets.group_by_day(series: false, &:created_at).map { |k, v| [k, v.size] }]
      next unless favorites_count_by_day.present?

      favorites_count_by_day.each do |date, count|
        p "Saving favorite counts for athlete: #{athlete.id} on #{date}"
        ara = AthleteActivityAnalysis.find_or_create_by(athlete_id: athlete.id, as_of: date, dow: date.strftime('%A'))
        next unless ara.present?
        next if ara.likes == count
        ara.likes = count
        ara.save!
      end
    end
    end_time = Time.now
    p "Began Athlete Report Populate at #{start_time}, finished at #{end_time}, total duration: #{TimeDifference.between(start_time, end_time).humanize}"
  end

  desc 'Populate Sentiment'
  task populate_sentiment: :environment do
    start_time = Time.now
    p "Began at #{start_time}"
    athletes = Athlete.all
    comprehend_client = Aws::Comprehend::Client.new

    athletes.each do |athlete|
      # get the max date of sentiment Analysis
      athlete_sentiment = AthleteSentimentAnalysis.where(athlete_id: athlete.id)
      max_sentiment_date = athlete_sentiment.top(:as_of).max.first if athlete_sentiment.present?
      tweets = athlete.twitter_profile.tweets.where("text not like 'RT @%'")
      tweets = tweets.where(created_at: max_sentiment_date.to_date..Time.current) if max_sentiment_date.present?

      tweet_text_by_day = {}
      tweets.each { |t| tweet_text_by_day[t.created_at.to_date] = t.text + ' ' }
      # I'm looping twice because I couldn't get the hash to populate with all the text concatenated in one call
      tweets.each { |t| tweet_text_by_day[t.created_at.to_date] += t.text + ' ' }

      next unless tweet_text_by_day.present?
      tweet_text_by_day.each do |date, _text|
        p "Saving daily tweet sentiment for athlete: #{athlete.id} on #{date}"
        # Make call to AWS comprehend for sentiment
        begin
          aws_sentiment_resp = comprehend_client.detect_sentiment(
            text: _text.byteslice(0...4999), # required
            language_code: 'en', # required, accepts en, es, fr, de, it, pt
          )
        rescue StandardError => exc
          p "Exception while checking sentiment: #{exc}"
        end

        next unless aws_sentiment_resp.present?
        asa = AthleteSentimentAnalysis.find_or_create_by(athlete_id: athlete.id, as_of: date)
        next unless asa.present?
        asa.sentiment = aws_sentiment_resp.sentiment #=> String, one of "POSITIVE", "NEGATIVE", "NEUTRAL", "MIXED"
        asa.positive = aws_sentiment_resp.sentiment_score.positive #=> Float
        asa.negative = aws_sentiment_resp.sentiment_score.negative #=> Float
        asa.neutral = aws_sentiment_resp.sentiment_score.neutral #=> Float
        asa.mixed = aws_sentiment_resp.sentiment_score.mixed
        asa.save!
      end
    end
    end_time = Time.now
    p "Began Athlete Sentiment Populate at #{start_time}, finished at #{end_time}, total duration: #{TimeDifference.between(start_time, end_time).humanize}"
  end
end
