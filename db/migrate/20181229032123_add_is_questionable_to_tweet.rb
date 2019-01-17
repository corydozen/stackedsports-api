class AddIsQuestionableToTweet < ActiveRecord::Migration[5.2]
  def change
    add_column :tweets, :is_questionable, :boolean, default: false
  end
end
