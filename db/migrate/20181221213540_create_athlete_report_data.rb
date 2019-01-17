class CreateAthleteReportData < ActiveRecord::Migration[5.2]
  def change
    create_table :athlete_report_data do |t|
      t.datetime :as_of
      t.references :athlete, foreign_key: true
      t.references :user, foreign_key: true
      t.references :organization, foreign_key: true
      t.integer :retweets, default: 0
      t.integer :likes, default: 0
      t.integer :mentions, default: 0
      t.integer :dms, default: 0
      t.integer :sms, default: 0

      t.timestamps
    end
  end
end
