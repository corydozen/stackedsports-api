module MessagesHelper
  def self.send_sms(_sender, _recipient, _message, _name = nil, _media = nil)
    return { 'status' => 'error', 'response' => 'Sender must have a text number' } unless _sender.sms_number.present? && _sender.sms_number.number.present?
    return { 'status' => 'error', 'response' => 'Recipient must have a text number' } unless _recipient.phone.present?
    return { 'status' => 'error', 'response' => 'Message cannot be empty, must have either text or media' } unless _message.present? || _media.present?

    begin
      client = Bandwidth::Client.new(
        user_id: ENV.fetch('BANDWIDTH_USER_ID'),
        api_token: ENV.fetch('BANDWIDTH_API_TOKEN'),
        api_secret: ENV.fetch('BANDWIDTH_API_SECRET')
      )
    rescue StandardError => exc
      return { 'status' => 'error', 'response' => exc.message }
    end

    message = _name.present? ? _message.gsub('::name::', _name) : _message.gsub('::name::', '')

    begin
      if _media.present?
        response = Bandwidth::Message.create(client,
                                             from: _sender.sms_number.number,
                                             to: _recipient.phone,
                                             text: message,
                                             media: _media,
                                             callback_url: "#{ENV.fetch('BANDWIDTH_CALLBACK_URL')}/sms_events")
      else
        response = Bandwidth::Message.create(client,
                                             from: _sender.sms_number.number,
                                             to: _recipient.phone,
                                             text: message,
                                             receipt_requested: 'all',
                                             callback_url: "#{ENV.fetch('BANDWIDTH_CALLBACK_URL')}/sms_events")
      end
    rescue Bandwidth::Errors::GenericError => e
      if e.code == 'too-many-requests' || e.code == 'message-rate-limit'
        return { 'status' => 'rate_limited', 'response' => error.message, 'until' => error.rate_limit.reset_in + 1 }
      end
    rescue StandardError => exc
      return { 'status' => 'error', 'response' => exc.message }
    end

    # SUCCESS
    { 'id' => response[:message_id], 'status' => 'sent', 'response' => nil }
  end

  def self.send_twitter_dm(_oauth_token, _oauth_token_secret, message, recipient, name = nil, media = nil)
    # p "****** Debug Param info ******"
    # p "OAuth Token: #{_oauth_token}"
    # p "OAuth Secret: #{_oauth_token_secret}"
    # p "Message: #{message}"
    # p "Recipient: #{recipient}"
    # p "Name: #{name}"
    # p "Media: #{media}"

    begin
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['RS_TWITTER_API_KEY']
        config.consumer_secret     = ENV['RS_TWITTER_API_SECRET']
        config.access_token        = _oauth_token
        config.access_token_secret = _oauth_token_secret
      end
    rescue StandardError => exc
      p exc
      return { 'status' => 'error', 'response' => exc.message }
    end

    # p "****** Debug Twitter Client info ******"
    # p "Twitter Client: #{client.inspect}"

    # Need to lookup the user id
    begin
      user_id = client.user(recipient).id

      # p "****** Debug Twitter User Look up info ******"
      # p "User: #{user_id}"
    rescue StandardError => exc
      p exc
      return { 'status' => 'error', 'response' => exc.message }
    end

    response = nil
    # Strip out the placeholder if the name is not present
    message = name.present? ? message.gsub('::name::', name) : message.gsub('::name::', '') if message.present?

    # p "****** Debug Message after Gsub name ******"
    # p "Message: #{message}"
    begin
      if media.present?
        response = client.create_direct_message_event_with_media_id(user_id, message, media)
      else
        response = client.create_direct_message_event(user_id, message)
      end
      # p "****** Debug Response info ******"
      # p "Response: #{response}"
    rescue Twitter::Error::TooManyRequests => error
      # NOTE: Your process could go to sleep for up to 15 minutes but if you
      # retry any sooner, it will almost certainly fail with the same exception.
      p "Rate Limit Error: #{error}"
      return { 'status' => 'rate_limited', 'response' => error.message, 'until' => error.rate_limit.reset_in + 1 }
      # sleep error.rate_limit.reset_in + 1
      sleep 5
      retry
      # rescue Twitter::Error::Forbidden => error
      #   # NOTE: Your process could go to sleep for up to 15 minutes but if you
      # retry any sooner, it will almost certainly fail with the same exception.
      # sleep error.rate_limit.reset_in + 1
      # retry
    rescue StandardError => exc
      p exc
      return { 'status' => 'error', 'response' => exc.message }
    end

    { 'id' => response.id, 'status' => 'sent', 'response' => nil }
  end
end

# MessagesHelper.send_twitter_dm('485875301-llKvztq3AVpOHRTTVq0ZInLsjCKjc4KSpnZTQk83','eTHbiPxeY47Tfyyb5w6Rr4p5vBX3r9HIRyJ8yDEN3LQsK', 'Testing Message Helper', 'sql_ninja')
#
#
#
# client = Twitter::REST::Client.new do |config|
#   config.consumer_key        = ENV['RS_TWITTER_API_KEY']
#   config.consumer_secret     = ENV['RS_TWITTER_API_SECRET']
#   config.access_token        = '485875301-llKvztq3AVpOHRTTVq0ZInLsjCKjc4KSpnZTQk83'
#   config.access_token_secret = 'eTHbiPxeY47Tfyyb5w6Rr4p5vBX3r9HIRyJ8yDEN3LQsK'
# end
# result = MessagesHelper.send_twitter_dm('485875301-llKvztq3AVpOHRTTVq0ZInLsjCKjc4KSpnZTQk83', 'eTHbiPxeY47Tfyyb5w6Rr4p5vBX3r9HIRyJ8yDEN3LQsK', 'Testing Message Helper', 'bashbro2stacked')
#
# client.create_direct_message_event(user_id, 'Test')

# # single sms sends with call back
# Bandwidth::Message.create(client,
#                           from: '+16159420122',
#                           to: '+16154825646',
#                           text: 'callback Test, please reply',
#                           callback_url: 'https://e3e0d3a2.ngrok.io/sms_events',
#                           receipt_requested: 'all')

# # Multiple sms sends with call back
# Bandwidth::Message.create(client,
#                           [
#                             {
#                               from: '+16159420122',
#                               to: '+16154825646',
#                               text: 'callback Test, please reply',
#                               callback_url: 'https://e3e0d3a2.ngrok.io/sms_events',
#                               receipt_requested: 'all'
#                             },
#                             {
#                               from: '+16159420122',
#                               to: '+16159996350‬',
#                               text: 'callback Test, please reply',
#                               callback_url: 'https://e3e0d3a2.ngrok.io/sms_events',
#                               receipt_requested: 'all'
#                             }
#                           ])
#
# # Multiple sms sends in one message with media
# Bandwidth::Message.create(client,
#                           [
#                             {
#                               from: '+16159420122',
#                               to: '+16154825646',
#                               text: 'Media Test',
#                               media: 'https://starecat.com/content/wp-content/uploads/dont-worry-im-from-tech-support-cat-fixing-computer.jpg',
#                               callback_url: 'https://e3e0d3a2.ngrok.io/sms_events'
#                             },
#                             {
#                               from: '+16159420122',
#                               to: '+16159996350‬',
#                               text: 'Media Test with call back, please reply',
#                               media: 'https://starecat.com/content/wp-content/uploads/dont-worry-im-from-tech-support-cat-fixing-computer.jpg',
#                               callback_url: 'https://e3e0d3a2.ngrok.io/sms_events'
#                             }
#                           ])
#
# # Call test
# call = Bandwidth::Call.create(client, {:from => "+16159420122", :to => "+16154825646"})
