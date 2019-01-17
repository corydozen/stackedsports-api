class AddTwitterMediaStatusMessageToMedium < ActiveRecord::Migration[5.2]
  def change
    add_column :media, :twitter_media_status_message, :string
  end
end
