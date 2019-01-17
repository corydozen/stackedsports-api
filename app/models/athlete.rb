class Athlete < ApplicationRecord
  include Hashid::Rails
  # belongs_to :team
  belongs_to :twitter_profile
  has_one :twitter_cache_date

  validates :email, uniqueness: true, allow_blank: true, allow_nil: true
  validates :phone, uniqueness: true, allow_blank: true, allow_nil: true
  validates :twitter_profile_id, uniqueness: true
  has_many :team_athletes
  has_many :message_recipients
  has_many :messages, through: :message_recipients
  has_many :athlete_report_data
  has_many :athlete_activity_analyses
  has_many :athlete_sentiment_analyses

  acts_as_taggable_on :positions

  def last_messaged(current_user)
    return nil unless message_recipients.present?

    msg = message_recipients.where.not(sent_at: nil).order(sent_at: :desc).to_a.keep_if { |msg| msg.message.user_id == current_user.id }.first
    return msg.sent_at if msg.present?
  end

  # (twitter_profile.tweets + twitter_profile.favorite_tweets).group_by_hour_of_day(range: range, time_zone: _time_zone, &:created_at).count

  def most_active_day(start_range: 30.days.ago, _time_zone: nil)
    range = start_range.present? ? start_range..Time.now : nil
    mad = twitter_profile.tweets.group_by_day_of_week(:created_at, range: range, time_zone: _time_zone).count
    mad_max = mad.max_by { |_k, v| v } if mad.present?

    result = if mad_max.present?
               # p mad_max
               return 'Unknown' if mad_max[1] == 0

               Date::DAYNAMES[mad_max[0]]
             else
               'Unknown'
             end

    result
  end

  def most_active_time(start_range: 30.days.ago, _time_zone: nil)
    range = start_range.present? ? start_range..Time.now : nil
    mat = twitter_profile.tweets.group_by_hour_of_day(:created_at, range: range, time_zone: _time_zone).count
    mat_max = mat.max_by { |_k, v| v } if mat.present?
    result = if mat_max.present?
               return 'Unknown' if mat_max[1] == 0

               ApplicationHelper.hour_24_to_12(mat_max[0])
             else
               'Unknown'
             end

    result
  end

  def last_report
    nil
  end

  def self.admin_search(query)
    search_results = search(query, return_all: true)
    results = nil
    results = if search_results.present? && search_results.is_a?(Hash) && search_results[:athletes].present?
                search_results[:athletes]
              else
                search_results
              end
    results
  end

  # Returns athletes and/or twitter users that match a specified query.
  #
  # @param query [String] A search term.
  # @option return_all [String] Returns all users if query param is empty.
  # @option user_to_search_twitter_with [String] System user used to search twitter for users.
  # @return [Hash] Return an athletes array and twitter array that match a specified query with search metadata
  def self.search(query, return_all: false, user_to_search_twitter_with: nil, limit: 25, only_search_twitter: false)
    results = {}
    results[:athletes] = []
    results[:twitter] = []
    if query.present?
      query.tr(',', ' ').split(' ').each do |term|
        twitter_profiles = TwitterProfile.arel_table
        twitter_string_ids = Arel::Nodes::NamedFunction.new('CAST', [twitter_profiles[:id].as('VARCHAR')])
        matched_profile_ids = twitter_profiles.where(twitter_profiles[:screen_name].lower.matches("%#{term.downcase}%")).project(twitter_string_ids)

        athletes = if only_search_twitter
                     where(arel_table[:twitter_profile_id]
                     .in(matched_profile_ids)).distinct.limit(limit)
                   else
                     where(arel_table[:twitter_profile_id]
                     .in(matched_profile_ids))
                       .or(where(arel_table[:first_name]
                     .lower
                     .matches("%#{term.downcase}%")))
                       .or(where(arel_table[:last_name]
                     .lower
                     .matches("%#{term.downcase}%")))
                       .or(where(arel_table[:nick_name]
                     .lower
                     .matches("%#{term.downcase}%")))
                       .or(where(arel_table[:email]
                     .lower
                     .matches("%#{term.downcase}%")))
                       .or(where(arel_table[:phone]
                     .lower
                     .matches("%#{term.downcase}%")))
                       .distinct.limit(limit)
                   end

        athletes.uniq.map { |athlete| results[:athletes] << athlete unless results[:athletes].include?(athlete) }

        next unless user_to_search_twitter_with.present?

        begin
          user_to_search_twitter_with.search_twitter_users(term).map { |tu| results[:twitter] << tu }
        rescue StandardError => error
          p error
          p 'An error ocurred while searching twitter.'
        end
      end
    elsif return_all
      results = all.limit(limit)
    end

    results
  end

  def as_json(options = {})
    super(options).merge(id: to_param)
  end

  def get_oc_tweets(start_date = Date.yesterday.beginning_of_day, end_date = Date.yesterday.end_of_day)
    # Get OC settings
    football_sport_id = Sport.find_by(name: 'Football')
    oc_settings = CoEmailSetting.first

    offer_keywords = oc_settings.offer_keywords.split(',')
    commit_keywords = oc_settings.commit_keywords.split(',')

    organizations = Organization.all
    org_name_keywords = {}
    org_nickname_keywords = {}
    org_mascot_keywords = {}
    organizations.each do |org|
      org_name_keywords[org.id] = org.name.downcase if org.name.present?
      org_nickname_keywords[org.id] = org.nickname.downcase if org.nickname.present?
      org_mascot_keywords[org.id] = org.mascot.downcase if org.mascot.present?
    end

    org_alias_keywords = {}
    aliases = OrganizationAlias.all
    aliases.each { |a| org_alias_keywords[a.organization_id] = a.alias.downcase; }

    # Get tweets from yesterday
    # p twitter_profile.tweets.where('created_at >= ? and created_at <= ?', Date.yesterday.beginning_of_day, Date.yesterday.end_of_day).to_sql if twitter_profile.present? &&  twitter_profile.tweets.present?
    tweets = twitter_profile.tweets.where(created_at: start_date..end_date) if twitter_profile.present?
    if tweets.present?
      tweets.each do |tweet|
        # Skip retweets
        next if tweet.text.starts_with?('RT @')

        # Build permalink
        begin
          permalink = nil
          if tweet.urls.present? && JSON.parse(tweet.urls.gsub(/:([a-zA-z]+)/, '"\\1"').gsub('=>', ': ')).present?
            urls = JSON.parse(tweet.urls.gsub(/:([a-zA-z]+)/, '"\\1"').gsub('=>', ': '))
            urls = urls.first if urls.is_a? Array

            permalink = urls.symbolize_keys
            if permalink[:expanded_url].present?
              permalink = permalink[:expanded_url]
            end
          end
          permalink ||= "https://twitter.com/#{twitter_profile.screen_name}/status/#{tweet.id}"
        end

        # Try to find Organization
        begin
          # This (.gsub(/[^[:alnum:][:blank:][:punct:]]/, '').squeeze(' ').strip) removes emojis
          tweet_words = tweet.text.delete('#').delete('@').gsub(/[^[:alnum:][:blank:][:punct:]]/, '').squeeze(' ').strip.split(' ')
          matched_org = nil
          program = nil
          # 1. Compare org name to tweet text
          tweet_words.each do |word|
            # Strip off punctuations
            word = word.gsub(/[^a-z0-9]/i, '')
            matched_org ||= Organization.find_by(id: org_name_keywords.key(word.downcase))
            break if matched_org.present?

            matched_org ||= Organization.find_by(id: org_nickname_keywords.key(word.downcase))
            break if matched_org.present?

            matched_org ||= Organization.find_by(id: org_mascot_keywords.key(word.downcase))
            break if matched_org.present?

            matched_org ||= Organization.find_by(id: org_alias_keywords.key(word.downcase))
            break if matched_org.present?
          end

          unless matched_org.present?
            # if we got here then none of our current data was useful, so let's see if AWS comprehend can help
            comprehend_client = Aws::Comprehend::Client.new
            resp = comprehend_client.detect_entities(
              text: tweet.text,
              language_code: 'en'
            )

            resp.entities.each do |entity|
              program ||= entity.text if entity.text.present? && (entity.type == 'LOCATION' || entity.type == 'ORGANIZATION')
              break if program.present?
            end

            # Try to match the org off the entity as a last ditch effort
            if program.present?
              program.split(' ').each do |word|
                # Strip off punctuations
                word = word.gsub(/[^a-z0-9]/i, '')
                matched_org ||= Organization.find_by(id: org_name_keywords.key(word.downcase))
                break if matched_org.present?

                matched_org ||= Organization.find_by(id: org_nickname_keywords.key(word.downcase))
                break if matched_org.present?

                matched_org ||= Organization.find_by(id: org_mascot_keywords.key(word.downcase))
                break if matched_org.present?

                matched_org ||= Organization.find_by(id: org_alias_keywords.key(word.downcase))
                break if matched_org.present?
              end
              matched_org ||= Organization.find_by(id: org_name_keywords.key(program.downcase))
              matched_org ||= Organization.find_by(id: org_nickname_keywords.key(program.downcase))
              matched_org ||= Organization.find_by(id: org_mascot_keywords.key(program.downcase))
              matched_org ||= Organization.find_by(id: org_alias_keywords.key(program.downcase))
            end
          end
        end

        # Set conference and program_name
        begin
          conference = nil
          program_name = nil
          if matched_org.present?
            if matched_org.teams.present?
              # Find the football team for the org
              football_team = matched_org.teams.find_by(sport_id: football_sport_id)
              conference = football_team.conference.name if football_team.conference.present?
            end

            program_name = (matched_org.nickname || matched_org.name)
          else
            program_name = program.present? ? program : 'UNKNOWN'
          end
        end

        if offer_keywords.any? { |keyword| tweet.text.downcase.include?(keyword.downcase) }
          tweet.is_offer = true
          tweet.save!
          # See if the tweet is an offer
          TempCommitOffer.find_or_create_by(
            organization_id: (matched_org.present? ? matched_org.id : nil),
            program_name: program_name,
            conference: conference,
            recruit_name: "#{first_name} #{last_name}",
            position: position_list,
            grad_year: grad_year,
            high_school: high_school,
            state: state,
            twitter_handle: twitter_profile.screen_name,
            tweet_text: tweet.text,
            tweet_permalink: (permalink.present? ? permalink : nil),
            deleted: false,
            created_at: tweet.created_at,
            updated_at: tweet.updated_at,
            keyword: 'Offer',
            grouping: 'Offer Tweets'
          )
        end

        next unless commit_keywords.any? { |keyword| tweet.text.downcase.include?(keyword.downcase) }

        tweet.is_commit = true
        tweet.save!
        # See if the tweet is a commit
        TempCommitOffer.find_or_create_by(
          organization_id: (matched_org.present? ? matched_org.id : nil),
          program_name: program_name,
          conference: conference,
          recruit_name: "#{first_name} #{last_name}",
          position: position_list,
          grad_year: grad_year,
          high_school: high_school,
          state: state,
          twitter_handle: twitter_profile.screen_name,
          tweet_text: tweet.text,
          tweet_permalink: (permalink.present? ? permalink : nil),
          deleted: false,
          created_at: tweet.created_at,
          updated_at: tweet.updated_at,
          keyword: 'Commit',
          grouping: 'Commit Tweets'
        )
      end
    end
  end
end
