class AthleteReport
  def self.my_team_engagement(athlete, organization, start_date = 30.days.ago)
    athlete.athlete_report_data.where(organization_id: organization, as_of: start_date..Time.now).calculate_all(likes: 'sum(likes)', retweets: 'sum(retweets)', mentions: 'sum(mentions)', dms: 'sum(dms)', sms: 'sum(sms)', total: 'sum(likes+retweets+mentions+dms+sms)')
  end

  def self.active_days(athlete, tz = nil, start_date = 30.days.ago)
    # athlete.athlete_activity_analyses.group(:dow).select('dow, sum(tweets+retweets+likes) as activity').order('activity desc')
    athlete.athlete_activity_analyses.group_by_day_of_week(:as_of, range: start_date..Time.now, format: '%a', time_zone: tz).sum('tweets+retweets+likes')
  end

  def self.active_hours(athlete, tz = nil, start_date = 30.days.ago)
    athlete.twitter_profile.tweets.group_by_hour_of_day(:created_at, range: start_date..Time.now, format: '%l %P', time_zone: tz).count
  end

  def self.sentiment_analysis(athlete, start_date = 30.days.ago)
    sentiment = athlete.athlete_sentiment_analyses.where(as_of: start_date..Time.now).calculate_all(positive: 'avg(positive)', negative: 'avg(negative)', neutral: 'avg(neutral)', mixed: 'avg(mixed)')
    results = {}
    max_sent = sentiment.max_by { |_k, v| v }
    results[:sentiment] = max_sent[1].present? ? max_sent[0].to_s.titleize : 'Unknown'
    results[:chart_data] = (sentiment.map { |k, v| { name: k, data: v } })

    results
  end

  def self.program_engagement(athlete, start_date = 30.days.ago)
    program_json = athlete.athlete_report_data.joins(:organization).group('organizations.nickname').group_by_day(:as_of, format: '%Y-%m-%d', range: start_date..Time.now, series: true, default_value: 0).sum('likes+retweets+mentions').chart_json
    # program_details_json = athlete.athlete_report_data.joins(:organization).group('organizations.name').group_by_day(:as_of, format: '%Y-%m-%d', range: start_date..Time.now, series: true, default_value: 0).calculate_all(likes: 'sum(likes)', retweets: 'sum(retweets)', mentions: 'sum(mentions)').chart_json
    programs = JSON.parse(program_json)
    # p programs
    programs_running_totals = []
    programs.each do |program|
      color = Organization.find_by(nickname: program['name']).primary_color
      total = 0
      program['data'].sort_by! { |d| d[0] }
      data = program['data'].map { |d| total += d[1]; [d[0].to_date, total] }
      programs_running_totals << {
        name: program['name'],
        data: data,
        color: (color.present? ? color : nil)
      }
    end
    # p programs_running_totals
    programs_running_totals
  end

  def self.coach_engagement(athlete, start_date = 30.days.ago)
    engagement_data = athlete.athlete_report_data.where(as_of: start_date..Time.now)
    # athlete.athlete_report_data.joins(:organization).joins(:user).group('organizations.name, users.id, athlete_report_data.as_of').group_by_day(:as_of, time_zone: false, range: start_date..Time.now).calculate_all(likes: 'sum(likes)', retweets: 'sum(retweets)', mentions: 'sum(mentions)', dms: 'sum(dms)', sms: 'sum(sms)', total: 'sum(likes+retweets+mentions+dms+sms)').chart_json

    # athlete.athlete_report_data.joins(:organization).where(as_of: start_date..Time.now, organization_id: 50).calculate_all(likes: 'sum(likes)', retweets: 'sum(retweets)', mentions: 'sum(mentions)', dms: 'sum(dms)', sms: 'sum(sms)', total: 'sum(likes+retweets+mentions+dms+sms)')

    org_users = engagement_data.pluck('organization_id, user_id').uniq
    athlete_is_following = []
    athlete_is_followed_by = []

    org_users.each do |org_id, user_id|
      user = User.find(user_id)

      if user.primary_twitter_profile.present? && athlete.twitter_profile.present? && athlete.twitter_profile.followers.present? && athlete.twitter_profile.followers.exists?(follower_id: user.primary_twitter_profile.first.id)
        athlete_is_followed_by << {
          organization_id: org_id,
          user_id: user_id,
          coach_name: user.primary_twitter_profile.first.name,
          screen_name: user.primary_twitter_profile.first.screen_name,
          profile_image: user.primary_twitter_profile.first.profile_image
        }
      end

      next unless athlete.twitter_profile.present? && user.primary_twitter_profile.present? && user.primary_twitter_profile.first.followers.present? && user.primary_twitter_profile.first.followers.exists?(follower_id: athlete.twitter_profile.id).present?

      athlete_is_following << {
        organization_id: org_id,
        user_id: user_id,
        coach_name: user.primary_twitter_profile.first.name,
        screen_name: user.primary_twitter_profile.first.screen_name,
        profile_image: user.primary_twitter_profile.first.profile_image
      }
    end

    # Get uniq list of programs from engagement
    programs = engagement_data.map do |ed|
      {
        id: ed.organization.id,
        name: ed.organization.nickname,
        logo: ed.organization.logo.url(:thumb),
        total_engagement: athlete.athlete_report_data.where(as_of: start_date..Time.now, organization_id: ed.organization.id).calculate_all(likes: 'sum(likes)', retweets: 'sum(retweets)', mentions: 'sum(mentions)', total: 'sum(likes+retweets+mentions)'),
        follower_data: {
          is_following: athlete_is_following.select { |fb| fb[:organization_id] == ed.organization.id },
          is_followed_by: athlete_is_followed_by.select { |fb| fb[:organization_id] == ed.organization.id }
        },
        coach_engagement: athlete.athlete_report_data.where(as_of: start_date..Time.now, organization_id: ed.organization.id).group(:user_id).calculate_all(likes: 'sum(likes)', retweets: 'sum(retweets)', mentions: 'sum(mentions)', total: 'sum(likes+retweets+mentions)')
      }
    end.uniq

    programs.sort_by! { |ce| ce[:total_engagement][:total] }.reverse!
  end

  def self.tweet_content(athlete, start_date = 365.days.ago)
    tweets = athlete.twitter_profile.tweets.where(created_at: start_date..Time.now)
    qc = tweets.to_a.keep_if(&:is_questionable)
    ql = athlete.twitter_profile.favorite_tweets.keep_if { |t| t.created_at >= start_date && t.is_questionable } if athlete.twitter_profile.favorite_tweets.present?

    # This should only be original content
    ct = tweets.where("lower(tweets.text) like '%camp%'")
    vt = tweets.where("lower(tweets.text) like '%visit%'")
    offers = tweets.to_a.keep_if(&:is_offer)
    commits = tweets.to_a.keep_if(&:is_commit)

    content = {
      questionable_tweets: qc,
      questionable_likes: ql,
      commits: commits,
      offers: offers,
      camp_visits: ct + vt
    }

    content
  end
end
