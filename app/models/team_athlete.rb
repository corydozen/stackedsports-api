class TeamAthlete < ApplicationRecord
  include Hashid::Rails
  belongs_to :athlete
  belongs_to :team
  has_many :sms_events

  acts_as_taggable_on :positions

  # Returns athletes and/or twitter users that match a specified query.
  #
  # @param query [String] A search term.
  # @option return_all [String] Returns all users if query param is empty.
  # @option user_to_search_twitter_with [String] System user used to search twitter for users.
  # @return [Hash] Return an athletes array and twitter array that match a specified query with search metadata
  def self.search(query, current_user_team_id)
    results = all
    if query.present?
      query.tr(',', ' ').split(' ').each do |term|
        term = term.strip
        twitter_profiles = TwitterProfile.arel_table
        twitter_string_ids = Arel::Nodes::NamedFunction.new('CAST', [twitter_profiles[:id].as('VARCHAR')])
        matched_profile_ids = twitter_profiles.where(twitter_profiles[:screen_name].lower.matches("%#{term.downcase}%")).project(twitter_string_ids)
        athlete_records = Athlete.arel_table
        matched_athletes_on_twitter = athlete_records.where(athlete_records[:twitter_profile_id].in(matched_profile_ids)).project(athlete_records[:id])

        results = results.where(arel_table[:athlete_id]
        .in(matched_athletes_on_twitter))
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
      end
    end
    results.where(team_id: current_user_team_id)
  end

  def add_tag(tag, current_user)
    owned_tag_list = all_tags_list - tag_list
    owned_tag_list += [tag]
    current_user.tag(self, with: stringify(owned_tag_list), on: :tags)
    save
  end

  def remove_tag(tag, current_user)
    owned_tag_list = all_tags_list - tag_list
    owned_tag_list -= [tag]
    current_user.tag(self, with: stringify(owned_tag_list), on: :tags)
    save
  end

  def add_position(position, current_user)
    # This method assumes you are passing the position abbreviation
    owned_tag_list = all_positions_list - position_list
    owned_tag_list += [position]
    current_user.tag(self, with: stringify(owned_tag_list), on: :positions)
    save
  end

  def remove_position(position, current_user)
    owned_tag_list = all_positions_list - position_list
    owned_tag_list -= [position]
    current_user.tag(self, with: stringify(owned_tag_list), on: :positions)
    save
  end

  def get_conversation(current_user)
    athlete_profile_image = athlete.twitter_profile.profile_image
    coach_profile_image = current_user.primary_twitter_profile.first.profile_image
    sms_messages = SmsEvent.where(user_id: current_user.id).as_json(only: [], methods: %i[message_type text created_at direction])
    dms = Message.joins(:message_recipients).where(user_id: current_user.id, message_recipients: { athlete_id: id }).as_json(only: [], methods: %i[message_type text created_at direction])
    conversation = {
      athlete_profile_image: athlete_profile_image,
      coach_profile_image: coach_profile_image,
      messages: (sms_messages.to_a + dms.to_a).sort_by { |m| m[:created_at] }
    }
  end

  def as_json(options = {})
    super(options).merge(id: to_param)
  end

  private

  def stringify(tag_list)
    tag_list.inject('') { |memo, tag| memo += (tag + ',') }[0..-1]
  end
end
