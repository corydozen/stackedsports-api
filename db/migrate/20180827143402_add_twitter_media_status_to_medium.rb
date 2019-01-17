class AddTwitterMediaStatusToMedium < ActiveRecord::Migration[5.2]
  def change
    add_column :media, :twitter_media_status, :string
  end
end
