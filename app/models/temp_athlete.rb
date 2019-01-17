class TempAthlete < ApplicationRecord

  # validates :email, uniqueness: true
  validates :twitter_handle, uniqueness: true
  # validates :mobile, uniqueness: true

  def self.search(query)
    if query.present?
      where(arel_table[:first_name].lower.matches("%#{query.downcase.to_s}%"))
      .or(where(arel_table[:last_name].lower.matches("%#{query.downcase.to_s}%")))
      .or(where(arel_table[:twitter_handle].lower.matches("%#{query.downcase.to_s}%")))
      .or(where(arel_table[:email].lower.matches("%#{query.downcase.to_s}%")))
    else
      all
    end
  end

  def twitter_profile
    TwitterProfile.find_by(screen_name: twitter_handle)
  end

  def rs_occurences
    occurences = RsAthlete.where('twitterProfile.screenName': twitter_handle)
    occurences.count
  end

  def get_oc_tweets
    # Get OC settings
    football_sport_id = Sport.find_by(name: 'Football')
    oc_settings = CoEmailSetting.first

    offer_keywords = oc_settings.offer_keywords.split(',')
    commit_keywords = oc_settings.commit_keywords.split(',')

    organizations = Organization.all
    org_name_keywords = {}
    org_nickname_keywords = {}
    org_mascot_keywords = {}
    organizations.each { |org|
      org_name_keywords[org.id] = org.name.downcase if org.name.present?;
      org_nickname_keywords[org.id] = org.nickname.downcase if org.nickname.present?
      org_mascot_keywords[org.id] = org.mascot.downcase if org.mascot.present?
    }

    org_alias_keywords = {}
    aliases = OrganizationAlias.all
    aliases.each { |a| org_alias_keywords[a.organization_id] = a.alias.downcase; }



    # Get tweets from yesterday
    # p twitter_profile.tweets.where('created_at >= ? and created_at <= ?', Date.yesterday.beginning_of_day, Date.yesterday.end_of_day).to_sql if twitter_profile.present? &&  twitter_profile.tweets.present?
    tweets = twitter_profile.tweets.where('created_at >= ? and created_at <= ?', Date.yesterday.beginning_of_day, Date.yesterday.end_of_day) if twitter_profile.present?
    tweets.each do |tweet|
      # Skip retweets
      next if tweet.text.starts_with?('RT @')

      # Build permalink
      begin
        permalink = nil
        if tweet.urls.present? && JSON.parse(tweet.urls.gsub(/:([a-zA-z]+)/,'"\\1"').gsub('=>', ': ')).present?
          urls = JSON.parse(tweet.urls.gsub(/:([a-zA-z]+)/,'"\\1"').gsub('=>', ': '))
          if urls.is_a? Array
            urls = urls.first
          end

          permalink = urls.symbolize_keys
          if permalink[:expanded_url].present?
            permalink = permalink[:expanded_url]
          end
        end
        permalink ||= "https://twitter.com/#{twitter_handle}/status/#{tweet.id}"
      end

      # Try to find Organization
      begin
        # This (.gsub(/[^[:alnum:][:blank:][:punct:]]/, '').squeeze(' ').strip) removes emojis
        tweet_words = tweet.text.gsub('#', '').gsub('@', '').gsub(/[^[:alnum:][:blank:][:punct:]]/, '').squeeze(' ').strip.split(' ')
        matched_org = nil
        program = nil
        # 1. Compare org name to tweet text
        tweet_words.each { |word|
          # Strip off punctuations
          word = word.gsub(/[^a-z0-9]/i, '')
          matched_org ||= Organization.find_by(id: org_name_keywords.key(word.downcase));
          break if matched_org.present?;
          matched_org ||= Organization.find_by(id: org_nickname_keywords.key(word.downcase));
          break if matched_org.present?;
          matched_org ||= Organization.find_by(id: org_mascot_keywords.key(word.downcase));
          break if matched_org.present?;
          matched_org ||= Organization.find_by(id: org_alias_keywords.key(word.downcase));
          break if matched_org.present?;
        }

        unless matched_org.present?
          # if we got here then none of our current data was useful, so let's see if AWS comprehend can help
          comprehend_client = Aws::Comprehend::Client.new
          resp = comprehend_client.detect_entities({
            text: tweet.text,
            language_code: "en"
          })

          resp.entities.each { |entity|
            program ||= entity.text if entity.text.present? && (entity.type == 'LOCATION' || entity.type == 'ORGANIZATION')
            break if program.present?
          }

          # Try to match the org off the entity as a last ditch effort
          if program.present?
            program.split(' ').each { |word|
              # Strip off punctuations
              word = word.gsub(/[^a-z0-9]/i, '')
              matched_org ||= Organization.find_by(id: org_name_keywords.key(word.downcase));
              break if matched_org.present?;
              matched_org ||= Organization.find_by(id: org_nickname_keywords.key(word.downcase));
              break if matched_org.present?;
              matched_org ||= Organization.find_by(id: org_mascot_keywords.key(word.downcase));
              break if matched_org.present?;
              matched_org ||= Organization.find_by(id: org_alias_keywords.key(word.downcase));
              break if matched_org.present?;
            }
            matched_org ||= Organization.find_by(id: org_name_keywords.key(program.downcase));
            matched_org ||= Organization.find_by(id: org_nickname_keywords.key(program.downcase));
            matched_org ||= Organization.find_by(id: org_mascot_keywords.key(program.downcase));
            matched_org ||= Organization.find_by(id: org_alias_keywords.key(program.downcase));
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


      if offer_keywords.any?{|keyword| tweet.text.downcase.include?(keyword.downcase)}
        # See if the tweet is an offer
        TempCommitOffer.find_or_create_by(
          organization_id: (matched_org.present? ? matched_org.id : nil),
          program_name: program_name,
          conference: conference,
          recruit_name: "#{first_name} #{last_name}",
          position: positions,
          grad_year: grad_year,
          high_school: hs_name,
          state: state,
          twitter_handle: twitter_handle,
          tweet_text: tweet.text,
          tweet_permalink: (permalink.present? ? permalink : nil),
          deleted: false,
          created_at: tweet.created_at,
          updated_at: tweet.updated_at,
          keyword: 'Offer',
          grouping: 'Offer Tweets'
        )
      end

      if commit_keywords.any?{|keyword| tweet.text.downcase.include?(keyword.downcase)}
        # See if the tweet is a commit
        TempCommitOffer.find_or_create_by(
          organization_id: (matched_org.present? ? matched_org.id : nil),
          program_name: program_name,
          conference: conference,
          recruit_name: "#{first_name} #{last_name}",
          position: positions,
          grad_year: grad_year,
          high_school: hs_name,
          state: state,
          twitter_handle: twitter_handle,
          tweet_text: tweet.text,
          tweet_permalink: (permalink.present? ? permalink : nil),
          deleted: false,
          created_at: tweet.created_at,
          updated_at: tweet.updated_at,
          keyword: 'Commit',
          grouping: 'Commit Tweets'
        )
      end
    end if tweets.present?
  end
end
