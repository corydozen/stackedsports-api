class CreateCoEmailSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :co_email_settings do |t|
      t.string :campaign_id
      t.string :list_id

      t.timestamps
    end
  end
end
