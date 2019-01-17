require 'twitter/rest/upload_utils'
module MediaHelper
  include Twitter::REST::UploadUtils
  def self.upload_media_to_twitter(_oauth_token, _oauth_token_secret, media)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['RS_TWITTER_API_KEY']
      config.consumer_secret     = ENV['RS_TWITTER_API_SECRET']
      config.access_token        = _oauth_token
      config.access_token_secret = _oauth_token_secret
    end

    begin
      # @param media [File] The file to be uploaded (PNG, JPG, GIF & MP4)
      # @param media_category_prefix [text] The prefix for the media object category (tweet, dm)
      # @param shared [boolean] Flag to determine whether the media object can be reused (true, false)
      return client.upload(media, media_category_prefix: 'dm', shared: true)
    rescue => exc
      p exc
      # TODO: Add logging of media exceptions
    end
  end

  def self.update_media_status(media_record)
    # NOTE: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-finalize.html
    response = RequestHelper.request(media_record.oauth_token, media_record.oauth_secret, "/media/upload.json?command=STATUS&media_id=#{media_record.twitter_media_id}", 'get') if media_record.oauth_token.present?
    if response.present?
      p response
      p "Previous Media State: #{media_record.twitter_media_status}"
      media_record.update_attributes(twitter_media_status: response['processing_info']['state'])
      media_record.update_attributes(twitter_media_status: response['processing_info']['error']['message']) if response['processing_info']['state'] == 'failed'
      p "Current Media State: #{media_record.twitter_media_status}"
    end
  end

  def self.update_message_media_status(message)
    response = RequestHelper.request(message.oauth_token, message.oauth_secret, "/media/upload.json?command=STATUS&media_id=#{message.platform_media_id}", 'get') if message.oauth_token.present?
    if response.present?
      message.update_attributes(platform_media_status: response['processing_info']['state'])
    end
  end
end
