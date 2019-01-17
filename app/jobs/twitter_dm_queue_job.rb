class TwitterDMQueueJob < ApplicationJob
  queue_as :dm_messages

  def perform(scheduled_time)
    process_twitter_queue(scheduled_time)
    process_old_twitter_queue(scheduled_time)
  end

  private

  def process_twitter_queue(scheduled_time)
    p "Starting twitter message queue at #{Time.at(scheduled_time)}"
    # Get all messages ready to send based on send_at

    platform = Platform.twitter.first

    messages = Message.where(status: 'Pending').or(Message.where(status: 'In Progress'))
                      .where.not(sender: nil)
                      .includes(:message_recipients)
                      .joins(:message_recipients)
                      .where(message_recipients: { platform_id: platform.id, status: 'pending' })
                      .where('message_recipients.send_at <= ?', Time.at(scheduled_time))
    # .where(message_recipients: { platform_id: platform.id })
    # p "Message SQL CMD: #{messages.to_sql}"
    p "#{ActionController::Base.helpers.pluralize(messages.count, 'message')} to be sent"

    return unless messages.present?

    # Get unique list of senders
    senders = messages.pluck(:sender).uniq

    sender_statuses = []
    # For each sender, set the initial status to valid
    if senders.present?
      senders.each do |sender|
        sender_statuses << { 'handle' => sender[0...sender.index(':')], 'status' => 'valid' } if sender.present?
      end
    end

    messages.each do |message|
      # NOTE: getting the status for the current sender
      sender_status = sender_statuses.find { |sndr| sndr['handle'] == message.sender }
      # NOTE: Break if the sender status isn't valid
      break unless sender_status['status'] == 'valid'

      # Get all pending recipients for the message
      recipients = message.message_recipients.where(platform_id: platform.id, status: 'pending').where('send_at <= ?', Time.at(scheduled_time)).order('message_recipients.send_at, message_recipients.grouping desc').limit(100)
      # recipients = MessageRecipient.where(platform: 'twitter', message_id: message.id, status: 'pending').where('send_at <= ?', Time.at(scheduled_time))
      message.update(status: 'In Progress') if recipients.count > 0
      p "Message id: #{message.id} to be sent to #{ActionController::Base.helpers.pluralize(recipients.count, 'recipient')}"

      # if the media search above returned an object then we upload it to twitter
      if message.media_id.present? && !message.platform_media_id.present?
        media = Medium.find(message.media_id) if message.media_id.present?
        # temp_file = Paperclip.io_adapters.for(media.object).read
        temp_file = Tempfile.new([media.object_file_name[0...-4], media.object_file_name[-4..-1]])
        temp_file.binmode
        # p temp_file
        if temp_file.present?
          media.object.copy_to_local_file(:original, temp_file.path)
          begin
            twitter_media = MediaHelper.upload_media_to_twitter(message.oauth_token, message.oauth_secret, temp_file)
            if twitter_media.present?
              message.update_attributes(platform_media_id: twitter_media[:media_id_string])
              twitter_media[:processing_info].present? ? MediaHelper.update_message_media_status(message) : message.update(platform_media_status: 'succeeded')
            end
          rescue StandardError => ex
            p "The following error occurred while uploading media id: #{message.media_id} to twitter: #{ex.inspect}"
          end
        end

      elsif message.platform_media_id.present? && message.platform_media_status != 'succeeded'
        # We have the media id, but the status is still not succeeded so let's check again
        MediaHelper.update_message_media_status(message)
      end

      # NOTE: Adding a self sent message on bulk messages to ensure that media is valid, due to quirk with twitter media conversion on pngs.
      # TODO: this is likely to become a setting on the message so building this to read a variable in the mean
      send_to_self = true

      if send_to_self && recipients.count > 1
        MessagesHelper.send_twitter_dm(
          message.oauth_token,
          message.oauth_secret,
          message.body,
          message.sender,
          nil,
          message.platform_media_id
        )
      end

      catch :rate_limited do
        # Attempt to send message and record status on recipient
        recipients.each do |rec|
          # NOTE: Break if the sender status isn't valid, assuming we got this far...
          break unless sender_status['status'] == 'valid'

          # Update recipients based on media
          if message.platform_media_id
            if message.platform_media_status == 'failed'
              rec.status = 'error'
              rec.response = 'Attached media is in an errored state'
              break
            elsif message.platform_media_status == 'in_progress'
              rec.response = 'Attached media is still being processed'
              break
            elsif message.platform_media_status == 'pending'
              rec.response = 'Attached media is not ready'
              break
            end
          end

          result = MessagesHelper.send_twitter_dm(
            message.oauth_token,
            message.oauth_secret,
            message.body,
            rec.recipient,
            rec.name,
            message.platform_media_id
          )

          next unless result.present?

          if result['status'] == 'rate_limited'
            # Update all pending messages to have a new send_at and a response of rate_limited
            remaining_recipients = MessageRecipient.where(
              message_id: message.id,
              status: 'pending'
            ).update_all(
              send_at: result['until'],
              response: result['response']
            )
            throw :rate_limited
          end
          rec.platform_response_id = result['id']
          rec.status = result['status']
          rec.response = result['response']
          rec.sent_at = Time.now if result['status'] == 'sent'
          rec.save
        end
      end
      p "Message status: #{message.current_status}"
    end
    p "Ending twitter message queue at #{Time.now}"
  end

  def process_old_twitter_queue(scheduled_time)
    p "Starting twitter message queue at #{Time.at(scheduled_time)}"
    # Get all messages ready to send based on send_at

    platform = Platform.twitter.first

    messages = Message.where(status: 'Pending').or(Message.where(status: 'In Progress'))
                      .where.not(sender: nil)
                      .includes(:message_recipients)
                      .joins(:message_recipients)
                      .where(message_recipients: { status: 'pending' })
                      .where('message_recipients.send_at <= ?', Time.at(scheduled_time))
    # .where(message_recipients: { platform_id: platform.id })
    # p "Message SQL CMD: #{messages.to_sql}"
    p "#{ActionController::Base.helpers.pluralize(messages.count, 'message')} to be sent"

    return unless messages.present?

    # Get unique list of senders
    senders = messages.pluck(:sender).uniq

    sender_statuses = []
    # For each sender, set the initial status to valid
    if senders.present?
      senders.each do |sender|
        sender_statuses << { 'handle' => sender[0...sender.index(':')], 'status' => 'valid' } if sender.present?
      end
    end

    messages.each do |message|
      # NOTE: getting the status for the current sender
      sender_status = sender_statuses.find { |sndr| sndr['handle'] == message.sender }
      # NOTE: Break if the sender status isn't valid
      break unless sender_status['status'] == 'valid'

      # Get all pending recipients for the message
      recipients = message.message_recipients.where(platform: 'twitter', status: 'pending').where('send_at <= ?', Time.at(scheduled_time)).order('message_recipients.send_at, message_recipients.grouping desc').limit(100)
      # recipients = MessageRecipient.where(platform: 'twitter', message_id: message.id, status: 'pending').where('send_at <= ?', Time.at(scheduled_time))
      message.update(status: 'In Progress') if recipients.count > 0
      p "Message id: #{message.id} to be sent to #{ActionController::Base.helpers.pluralize(recipients.count, 'recipient')}"

      # if the media search above returned an object then we upload it to twitter
      if message.media_id.present? && !message.platform_media_id.present?
        media = Medium.find(message.media_id) if message.media_id.present?
        # temp_file = Paperclip.io_adapters.for(media.object).read
        temp_file = Tempfile.new([media.object_file_name[0...-4], media.object_file_name[-4..-1]])
        temp_file.binmode
        # p temp_file
        if temp_file.present?
          media.object.copy_to_local_file(:original, temp_file.path)
          begin
            twitter_media = MediaHelper.upload_media_to_twitter(message.oauth_token, message.oauth_secret, temp_file)
            if twitter_media.present?
              message.update_attributes(platform_media_id: twitter_media[:media_id_string])
              twitter_media[:processing_info].present? ? MediaHelper.update_message_media_status(message) : message.update(platform_media_status: 'succeeded')
            end
          rescue StandardError => ex
            p "The following error occurred while uploading media id: #{message.media_id} to twitter: #{ex.inspect}"
          end
        end

      elsif message.platform_media_id.present? && message.platform_media_status != 'succeeded'
        # We have the media id, but the status is still not succeeded so let's check again
        MediaHelper.update_message_media_status(message)
      end

      # NOTE: Adding a self sent message on bulk messages to ensure that media is valid, due to quirk with twitter media conversion on pngs.
      # TODO: this is likely to become a setting on the message so building this to read a variable in the mean
      send_to_self = true

      if send_to_self && recipients.count > 1
        MessagesHelper.send_twitter_dm(
          message.oauth_token,
          message.oauth_secret,
          message.body,
          message.sender,
          nil,
          message.platform_media_id
        )
      end

      catch :rate_limited do
        # Attempt to send message and record status on recipient
        recipients.each do |rec|
          # NOTE: Break if the sender status isn't valid, assuming we got this far...
          break unless sender_status['status'] == 'valid'

          # Update recipients based on media
          if message.platform_media_id
            if message.platform_media_status == 'failed'
              rec.status = 'error'
              rec.response = 'Attached media is in an errored state'
              break
            elsif message.platform_media_status == 'in_progress'
              rec.response = 'Attached media is still being processed'
              break
            elsif message.platform_media_status == 'pending'
              rec.response = 'Attached media is not ready'
              break
            end
          end

          result = MessagesHelper.send_twitter_dm(
            message.oauth_token,
            message.oauth_secret,
            message.body,
            rec.recipient,
            rec.name,
            message.platform_media_id
          )

          next unless result.present?

          if result['status'] == 'rate_limited'
            # Update all pending messages to have a new send_at and a response of rate_limited
            remaining_recipients = MessageRecipient.where(
              message_id: message.id,
              status: 'pending'
            ).update_all(
              send_at: result['until'],
              response: result['response']
            )
            throw :rate_limited
          end
          rec.platform_response_id = result['id']
          rec.status = result['status']
          rec.response = result['response']
          rec.sent_at = Time.now if result['status'] == 'sent'
          rec.save
        end
      end
      p "Message status: #{message.current_status}"
    end
    p "Ending twitter message queue at #{Time.now}"
  end
end
