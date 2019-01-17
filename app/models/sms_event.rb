class SmsEvent < ApplicationRecord
  belongs_to :team_athlete, optional: true
  belongs_to :user, optional: true

  scope :in_bound, -> { where(direction: 'in') }
  scope :out_bound, -> { where(direction: 'out') }

  def sender
    result = team_athlete.as_json(
      only: %i[id first_name last_name]
    )
  end

  # def last_message_from_sender(number)
  #   in_bound.where(team_athlete_id: number).order(time: :desc).first
  # end

  def message_type
    'sms'
  end
end
