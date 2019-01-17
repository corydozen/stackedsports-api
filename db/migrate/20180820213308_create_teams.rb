class CreateTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :photo_url
      t.string :phone
      t.datetime :trial_start_date
      t.string :override_plan_id
      t.references :organization, foreign_key: true
      t.string :stripe_subscription_id

      t.timestamps
    end
  end
end
