class CreateMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :media do |t|
      t.string :name

      t.timestamps
    end

    add_attachment :media, :object

    add_column :media, :twitter_media_id, :string
  end
end
