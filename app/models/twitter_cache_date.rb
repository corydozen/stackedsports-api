class TwitterCacheDate < ApplicationRecord
  belongs_to :athlete
  validates :athlete_id, uniqueness: true
end
