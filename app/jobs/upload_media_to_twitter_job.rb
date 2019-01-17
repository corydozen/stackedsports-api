class UploadMediaToTwitterJob < ApplicationJob
  queue_as :twitter

  def perform(media, token, secret)
    # Do something later
    # # NOTE: if media object was successfully created and the oauth fields are present then we can upload to twitter
    begin

      temp_file = Tempfile.new([ media.object_file_name[0...-4], media.object_file_name[-4..-1] ] )
      temp_file.binmode
      media.object.copy_to_local_file(:original, temp_file.path)

      twitter_media = MediaHelper.upload_media_to_twitter(token, secret, temp_file)

      media.update(twitter_media_id: twitter_media[:media_id_string]) if twitter_media[:media_id_string].present?
      twitter_media[:processing_info].present? ? MediaHelper.update_media_status( media) : media.update(twitter_media_status: 'succeeded')
    rescue StandardError => exc
      p exc
      # render json: {
      #   errors: Stitches::Error.new(code: 'upload_error', message: 'Error when uploading media to Twitter')
      # }, status: :unprocessable_entity and return
    end
  end
end
