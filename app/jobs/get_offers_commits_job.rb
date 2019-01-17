class GetOffersCommitsJob < ApplicationJob
  queue_as :default

  def perform(_scheduled_time)
    start_time = Time.now

    # Get yesterday's tweets (excluding RT)
    tweets = Tweet.where(Tweet.arel_table[:text].does_not_match('RT @%')).where(created_at: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day)
    if tweets.present?
      offers_commits_to_save = []
      football_sport_id = Sport.find_by(name: 'Football')
      oc_settings = CoEmailSetting.first

      offer_keywords = oc_settings.offer_keywords.split(',') if oc_settings.offer_keywords.present?
      commit_keywords = oc_settings.commit_keywords.split(',') if oc_settings.commit_keywords.present?

      raise StandardError, 'Keywords are missing in co_email_settings' unless offer_keywords.present? && commit_keywords.present?

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

      tweets.each do |tweet|
        # Skip the tweet unless it has offer or commit keywords
        next unless offer_keywords.any? { |keyword| tweet.text.downcase.include?(keyword.downcase) } || commit_keywords.any? { |keyword| tweet.text.downcase.include?(keyword.downcase) }

        # Get the profile that tweeted this message
        twitter_profile = tweet.twitter_profile
        # Get the athlete that this profile belongs to
        athlete = Athlete.find_by(twitter_profile_id: twitter_profile.id) if twitter_profile.present?
        # Move on if we don't have this athlete
        next unless athlete.present?

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
            matched_org ||= Organization.find_by(id: org_name_keywords.key(word.downcase)) if org_name_keywords.key(word.downcase).present?
            break if matched_org.present?

            matched_org ||= Organization.find_by(id: org_nickname_keywords.key(word.downcase)) if org_nickname_keywords.key(word.downcase).present?
            break if matched_org.present?

            matched_org ||= Organization.find_by(id: org_mascot_keywords.key(word.downcase)) if org_mascot_keywords.key(word.downcase).present?
            break if matched_org.present?

            matched_org ||= Organization.find_by(id: org_alias_keywords.key(word.downcase)) if org_alias_keywords.key(word.downcase).present?
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
                matched_org ||= Organization.find_by(id: org_name_keywords.key(word.downcase)) if org_name_keywords.key(word.downcase).present?
                break if matched_org.present?

                matched_org ||= Organization.find_by(id: org_nickname_keywords.key(word.downcase)) if org_nickname_keywords.key(word.downcase).present?
                break if matched_org.present?

                matched_org ||= Organization.find_by(id: org_mascot_keywords.key(word.downcase)) if org_mascot_keywords.key(word.downcase).present?
                break if matched_org.present?

                matched_org ||= Organization.find_by(id: org_alias_keywords.key(word.downcase)) if org_alias_keywords.key(word.downcase).present?
                break if matched_org.present?
              end
              matched_org ||= Organization.find_by(id: org_name_keywords.key(program.downcase)) if org_name_keywords.key(program.downcase).present?
              matched_org ||= Organization.find_by(id: org_nickname_keywords.key(program.downcase)) if org_nickname_keywords.key(program.downcase).present?
              matched_org ||= Organization.find_by(id: org_mascot_keywords.key(program.downcase)) if org_mascot_keywords.key(program.downcase).present?
              matched_org ||= Organization.find_by(id: org_alias_keywords.key(program.downcase)) if org_alias_keywords.key(program.downcase).present?
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
          offers_commits_to_save << TempCommitOffer.new(
            organization_id: (matched_org.present? ? matched_org.id : nil),
            program_name: program_name,
            conference: conference,
            recruit_name: "#{athlete.first_name} #{athlete.last_name}",
            position: athlete.position_list.to_s,
            grad_year: athlete.grad_year,
            high_school: athlete.high_school,
            state: athlete.state,
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
        offers_commits_to_save << TempCommitOffer.new(
          organization_id: (matched_org.present? ? matched_org.id : nil),
          program_name: program_name,
          conference: conference,
          recruit_name: "#{athlete.first_name} #{athlete.last_name}",
          position: athlete.position_list.to_s,
          grad_year: athlete.grad_year,
          high_school: athlete.high_school,
          state: athlete.state,
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
      TempCommitOffer.import(offers_commits_to_save, validate_uniqueness: true, on_duplicate_key_update: { conflict_target: %i[program_name recruit_name twitter_handle tweet_text keyword], columns: :all }) if offers_commits_to_save.present?
    end

    end_time = Time.now

    p "Began Offer/Commit check at #{start_time}, finished process at #{end_time}, total duration: #{TimeDifference.between(start_time, end_time).humanize}"
  end
end
