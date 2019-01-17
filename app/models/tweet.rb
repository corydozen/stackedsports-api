require 'upsert/active_record_upsert'
class Tweet < ApplicationRecord
  belongs_to :twitter_profile
  scope :questionable, -> { where(is_questionable: true) }
  scope :commits, -> { where(is_commit: true) }
  scope :offer, -> { where(is_offer: true) }
end
