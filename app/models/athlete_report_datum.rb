class AthleteReportDatum < ApplicationRecord
  belongs_to :athlete
  belongs_to :user
  belongs_to :organization
end
