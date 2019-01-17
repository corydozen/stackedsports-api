class Favorite < ApplicationRecord
  belongs_to :twitter_profile
  belongs_to :tweet
end
