class CreateTwitterProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :twitter_profiles do |t|
      t.bigint :twitter_id
      t.string :id_str
      t.string :name
      t.string :screen_name
      t.string :location
      t.string :profile_location
      t.string :description
      t.string :url
      t.boolean :protected
      t.integer :followers_count
      t.integer :friends_count
      t.integer :listed_count
      t.datetime :profile_created_at
      t.integer :favorites_count
      t.string :utc_offset
      t.string :time_zone
      t.boolean :geo_enabled
      t.boolean :verified
      t.integer :statuses_count
      t.string :lang
      t.boolean :contributors_enabled
      t.boolean :is_translator
      t.boolean :is_translation_enabled
      t.string :profile_background_color
      t.string :profile_background_image_url
      t.string :profile_background_image_url_https
      t.boolean :profile_background_tile
      t.string :profile_image_url
      t.string :profile_image_url_https
      t.string :profile_banner_url
      t.string :profile_link_color
      t.string :profile_sidebar_border_color
      t.string :profile_sidebar_fill_color
      t.string :profile_text_color
      t.boolean :profile_use_background_image
      t.boolean :has_extended_profile
      t.boolean :default_profile
      t.boolean :default_profile_image
      t.boolean :notifications
      t.string :translator_type

      t.timestamps
    end
  end
end
