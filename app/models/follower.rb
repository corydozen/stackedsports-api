class Follower < ApplicationRecord
  belongs_to :twitter_profile
  belongs_to :follower, class_name: 'TwitterProfile'

  validates_uniqueness_of :twitter_profile_id, scope: :follower_id
end
