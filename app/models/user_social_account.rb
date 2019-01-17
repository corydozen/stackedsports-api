class UserSocialAccount < ApplicationRecord
  include Hashid::Rails
  belongs_to :user
  belongs_to :platform

  scope :primary, -> { where(is_primary: true) }

  scope :twitter, -> {
    joins(:platform).merge(Platform.twitter)
    .joins('JOIN twitter_profiles ON twitter_profiles.id = user_social_accounts.platform_account_id::int')
  }


  def as_json(options = {})
    super(options).merge(id: to_param)
  end
end
