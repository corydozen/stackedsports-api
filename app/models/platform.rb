class Platform < ApplicationRecord
  scope :twitter, -> { where(name: 'Twitter') }
  scope :sms, -> { where(name: 'SMS') }
end
