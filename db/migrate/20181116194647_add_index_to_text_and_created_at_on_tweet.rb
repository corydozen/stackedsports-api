class AddIndexToTextAndCreatedAtOnTweet < ActiveRecord::Migration[5.2]
  def change
    unless index_exists? :tweets, [:text, :created_at], name: 'text_created_at_idx'
      add_index :tweets, [:text, :created_at], name: 'text_created_at_idx'
    end
  end
end
