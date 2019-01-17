class AddReferencesToSmsEvent < ActiveRecord::Migration[5.2]
  def change
    add_reference :sms_events, :user, foreign_key: true
    add_reference :sms_events, :team_athlete, foreign_key: true
  end
end
