class User < ApplicationRecord
  include Hashid::Rails
  has_many :team_users
  has_many :messages
  has_many :teams, through: :team_users
  alias_attribute :team_mates, :team_users
  alias_attribute :social_accounts, :user_social_accounts
  has_many :user_social_accounts
  has_many :messages
  has_one :twitter_user_rate_limit
  has_one :sms_number
  has_many :filters

  authenticates_with_sorcery!
  rolify

  acts_as_tagger

  after_create :assign_default_role
  after_create :create_twitter_rate_limit
  before_update :setup_activation, if: -> { email_changed? }
  after_update :send_activation_needed_email!, if: -> { previous_changes['email'].present? }
  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, uniqueness: true

  def owned_tags_on(context = nil)
    owned_tags.includes(:taggings).where(taggings: { context: context })
  end

  def assign_default_role
    add_role(:newuser) if roles.blank?
  end

  def create_twitter_rate_limit
    TwitterUserRateLimit.find_or_create_by(user_id: id)
  end

  def primary_twitter_profile
    TwitterProfile.where(id: social_accounts.primary.twitter.map { |t| t.platform_account_id.to_i })
  end

  def twitter_client
    psa = social_accounts.primary.twitter.first
    init_twitter_client(psa.oauth_token, psa.oauth_secret)
  end

  def twitter_profiles
    TwitterProfile.where(id: social_accounts.twitter.map { |t| t.platform_account_id.to_i })
  end

  def follow_on_twitter(athlete)
    raise StandardError, 'Athlete is missing twitter profile' unless athlete.twitter_profile.present?
    raise StandardError, 'User is missing primary twitter profile or profile is invalid' unless social_accounts.primary.present? && social_accounts.primary.oauth_token.present? && social_accounts.primary.oauth_secret.present?

    primary_twitter_account = social_accounts.primary

    coach = Coach.new(
      id: id,
      email: email,
      token: primary_twitter_account.oauth_token,
      secret: primary_twitter_account.oauth_secret
    )

    raise StandardError, 'Unable to access twitter client' unless coach.present?

    begin
      coach.twitter_client.follow(athlete.twitter_profile.twitter_id)
      # Ensure we have the follower relationship
      Follower.find_or_create_by(
        twitter_profile_id: primary_twitter_account.platform_account_id,
        follower_id: athlete.twitter_profile.id
      ).update(unfollow_date: nil)
    rescue StandardError => ex
      raise StandardError, 'Unable to follow athlete'
    end
  end

  def unfollow_on_twitter(athlete)
    raise StandardError, 'Athlete is missing twitter profile' unless athlete.twitter_profile.present?
    raise StandardError, 'User is missing primary twitter profile or profile is invalid' unless social_accounts.primary.present? && social_accounts.primary.oauth_token.present? && social_accounts.primary.oauth_secret.present?

    primary_twitter_account = social_accounts.primary

    coach = Coach.new(
      id: id,
      email: email,
      token: primary_twitter_account.oauth_token,
      secret: primary_twitter_account.oauth_secret
    )

    raise StandardError, 'Unable to access twitter client' unless coach.present?

    begin
      coach.twitter_client.unfollow(athlete.twitter_profile.twitter_id)
      # Ensure we have the follower relationship
      Follower.find_or_create_by(
        twitter_profile_id: primary_twitter_account.platform_account_id,
        follower_id: athlete.twitter_profile.id
      ).update(unfollow_date: Time.now)
    rescue StandardError => ex
      raise StandardError, 'Unable to follow athlete'
    end
  end

  def search_twitter_users(screen_name, count = 10)
    raise StandardError, 'screen_name to search is missing' unless screen_name.present?
    raise StandardError, 'User is missing primary twitter profile or profile is invalid' unless social_accounts.primary.present? && social_accounts.primary.first.oauth_token.present? && social_accounts.primary.first.oauth_secret.present?

    primary_twitter_account = social_accounts.primary.twitter.first

    coach = Coach.new(
      id: id,
      email: email,
      token: primary_twitter_account.oauth_token,
      secret: primary_twitter_account.oauth_secret
    )

    raise StandardError, 'Unable to access twitter client' unless coach.present?

    begin
      coach.twitter_client.user_search(screen_name, count: count)
    rescue StandardError => ex
      p ex
      raise StandardError, "Unable to find user with screen_name: #{screen_name}"
    end
  end

  def update_twitter_profile(twitter_profile)
    return unless twitter_profile.present?

    # raise StandardError, 'Unable to access twitter client' unless twitter.present?

    handle_or_id = twitter_profile.twitter_id.present? ? twitter_profile.twitter_id : twitter_profile.screen_name

    twitter_user = twitter_client.user(handle_or_id)

    raise StandardError, 'User not found on twitter' unless twitter_user.present?

    tp = twitter_profile

    tp.twitter_id = twitter_user.id if tp.twitter_id != twitter_user.id
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

  def self.search(query)
    if query.present?
      where(
        arel_table[:first_name]
        .lower
        .matches("%#{query.downcase}%")
      )
        .or(where(arel_table[:last_name]
        .lower
        .matches("%#{query.downcase}%")))
        .or(where(arel_table[:email]
        .lower
        .matches("%#{query.downcase}%")))
    else
      all
    end
  end

  def get_inbox
    sms_messages = SmsEvent.in_bound.where(user_id: id).joins(:team_athlete).group(
      "team_athletes.id,
      team_athletes.first_name,
      team_athletes.last_name,
      replace(sms_events.from, '+', '')"
    ).pluck(Arel.sql("json_build_object(
                       'team_athlete_id', team_athletes.id,
                       'first_name', team_athletes.first_name,
                       'last_name', team_athletes.last_name,
                       'message_type', 'sms',
                       'from', replace(sms_events.from, '+', ''),
                       'last_received_time', max(sms_events.time),
                       'unread', sum(case when sms_events.state = 'received' then 1 else 0 end),
                       'total', count(sms_events.*))"))

    sms_messages.each do |msg|
      msg[:profile_image] = TeamAthlete.find(msg['team_athlete_id']).athlete.twitter_profile.profile_image
      msg[:last_message_preview] = SmsEvent.where(direction: 'in', team_athlete_id: msg['team_athlete_id'], user_id: id).order(time: :desc).first.text
    end

    inbox = sms_messages
    # TODO: Build out twitter DM responses and merge them into @inbox
    inbox.sort_by { |msgs| msgs['last_received_time'] }.reverse.as_json if inbox
  end

  def as_json(options = {})
    super(options).merge(id: to_param)
  end

  private

  def init_twitter_client(token, secret)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['RS_TWITTER_API_KEY']
      config.consumer_secret     = ENV['RS_TWITTER_API_SECRET']
      config.access_token        = token
      config.access_token_secret = secret
    end

    client
  rescue StandardError => exc
    p exc
    nil
  end

  def pause_twitter(reset_at, duration, end_point)
    rate_limits = TwitterUserRateLimit.find_or_create_by(user_id: id)
    rate_limits.update_attribute(end_point.to_sym, reset_at)

    rate_limit_thread = Thread.new do
      Thread.current['counter'] = duration + 1

      (duration + 1).times do
        sleep 1
        Thread.current['counter'] -= 1
        # @paused_for = Thread.current['counter'];
        puts "#{id} - #{email} access to #{end_point} is paused for #{Thread.current['counter']} seconds"
      end
    end
    #   @paused_for = RateLimitHelper.wait_progress(duration + 1, "#{@id} - #{@email}")
    rate_limit_thread.join
    unpause_twitter(end_point)
  end

  def unpause_twitter(end_point)
    rate_limits = TwitterUserRateLimit.find_or_create_by(user_id: id)
    rate_limits.update_attribute(end_point.to_sym, nil)
  end
end
