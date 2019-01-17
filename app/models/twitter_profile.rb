require 'upsert/active_record_upsert'
class TwitterProfile < ApplicationRecord
  include Hashid::Rails
  has_many :tweets
  has_many :favorites
  has_many :followers

  before_save :downcase_fields

  validates :twitter_id, uniqueness: true, allow_blank: true, allow_nil: true

  def downcase_fields
    screen_name.downcase! if screen_name.present?
  end

  def original_tweets
    tweets.where("text not like 'RT @%'")
  end

  def retweets
    tweets.where("text like 'RT @%'")
  end

  def favorite_tweets
    return unless favorites.present?

    # favs = []
    # favorites.joins(:tweet).select('tweets.*').map { |f| favs << f }
    # favs
    favorites.map(&:tweet)
  end

  def mentions; end

  def coach_followers
    # This should only return the coaches for a given organization
    # coaches = Organization.all.map do |o|
    #   o.teams.first.users.map { |u| u.primary_twitter_profile.first.id if u.primary_twitter_profile.present? }.compact
    # end
    # cf = followers.where(follower_id: coaches).map(&:follower) if coaches.present?
    # f = TwitterProfile.where(id: cf) if cf.present?
    # f
  end

  def following_coaches
    # This should only return the coaches for a given organization
  end

  def profile_image
    # require 'rest_client'
    placeholder = 'https://s3.us-east-2.amazonaws.com/stakdsocial/media/general/athlete_not_found_alt.png'
    return placeholder unless profile_image_url_https.present?

    # response = RestClient.get(profile_image_url_https.to_s)
    image_exists = Faraday.head(profile_image_url_https.to_s).status == 200
    # image_exists = RestClient.head(profile_image_url_https.to_s).code != 404

    return placeholder unless image_exists

    profile_image_url_https.to_s
  end

  def as_json(options = {})
    super(options).merge(id: to_param)
  end
end
