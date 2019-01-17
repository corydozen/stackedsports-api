require 'upsert/active_record_upsert'
class TempCommitOffer < ApplicationRecord
  has_one :organization#, optional: true
end
