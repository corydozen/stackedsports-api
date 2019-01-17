class CreateSmsEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :sms_events do |t|
      t.string :event_type
      t.string :direction
      t.string :from
      t.string :to
      t.string :message_id
      t.string :message_uri
      t.string :text
      t.string :tag
      t.integer :segment_count
      t.string :application_id
      t.datetime :time
      t.string :state
      t.string :delivery_state
      t.string :delivery_code
      t.string :delivery_description
      t.string :media, array: true, default: []

      t.timestamps
    end
  end
end
