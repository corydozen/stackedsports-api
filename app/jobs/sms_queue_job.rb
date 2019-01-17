class SmsQueueJob < ApplicationJob
  queue_as :sms_messages

  def perform(scheduled_time)
    process_sms_queue(scheduled_time)
  end

  private

  def process_sms_queue(scheduled_time)
    p "Starting sms message queue at #{Time.at(scheduled_time)}"
    platform = Platform.sms.first
    messages = Message.where(status: 'Pending').or(Message.where(status: 'In Progress'))
                      .includes(:message_recipients)
                      .joins(:message_recipients)
                      .where(message_recipients: { platform_id: platform.id })
                      .where(message_recipients: { status: 'pending' })
                      .where('message_recipients.send_at <= ?', Time.at(scheduled_time))

    p "#{ActionController::Base.helpers.pluralize(messages.count, 'sms_message')} to be sent"
    return unless messages.present?

    messages.each do |message|
      recipients = message.message_recipients.where(platform_id: platform.id)
                          .where('send_at <= ?', Time.at(scheduled_time))
                          .order('message_recipients.send_at, message_recipients.grouping desc')
                          .limit(100)

      message.update(status: 'In Progress') if recipients.present? && recipients.count > 0
      p "Message id: #{message.id} to be sent to #{ActionController::Base.helpers.pluralize(recipients.count, 'recipient')}"

      # Get media if present
      media = Medium.find(message.media_id) if message.media_id.present?

      catch :rate_limited do
        # Attempt to send message and record status on recipient
        recipients.each do |_recipient|
          # Look up team athlete based on athlete id and sender team
          user = User.find(message.user_id)
          team_athlete = TeamAthlete.find_by(athlete_id: _recipient.athlete_id, team_id: user.teams.first.id)
          result = MessagesHelper.send_sms(
            user,
            team_athlete,
            message.body,
            _recipient.name,
            (media.present? ? media.object.url : nil)
          )

          # Sleep for 1 second to avoid carrier rate limiting
          sleep 1

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
          _recipient.platform_response_id = result['id']
          _recipient.status = result['status']
          _recipient.response = result['response']
          _recipient.sent_at = Time.now if result['status'] == 'sent'
          _recipient.save
        end
      end
      p "Message status: #{message.current_status}"
    end
    p "Ending sms message queue at #{Time.now}"
  end
end
