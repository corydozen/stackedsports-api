class MediaStatusUpdaterJob < ApplicationJob
  queue_as :twitter

  def perform(scheduled_time)
      p "Starting twitter media status update at #{Time.at(scheduled_time)}"
    # Do something later
    # Get all media objects that have been uploaded to twitter and the status
    # has not been checked or is pending or in_progress
    media = Medium.where("oauth_token is not null and twitter_media_id is not null and twitter_media_id != '' and ( twitter_media_status is null or twitter_media_status in ('pending', 'in_progress'))")

    media.each do |m|
      p "Updating status for media id: #{m.id}"
      MediaHelper.update_media_status(m)
    end
    p "Ending twitter media status update at #{Time.now}"
  end
end
