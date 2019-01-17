class SmsNumber < ApplicationRecord
  belongs_to :user
  has_many :messages
end
