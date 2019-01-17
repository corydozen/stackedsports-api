class Message < ApplicationRecord
  include Hashid::Rails
  has_many :message_recipients
  belongs_to :team, optional: true
  belongs_to :user, optional: true
  # has_many :medium
  # has_many :platforms
  alias_attribute :text, :body

  def message_type
    'dm'
  end

  def direction
    'out'
  end

  def self.status_order
    order("
        CASE
          WHEN messages.status = 'Draft' THEN 0
          ELSE 10
        END")
  end

  def media
    begin
      media = Medium.find(media_id) if media_id.present?
    rescue StandardError => exc
      p exc
    end
    if media.present?
      return media.as_json(only: [], methods: %i[id name file_type urls])
    else
      {}
    end
  end

  def next_send_at
    next_message = message_recipients.where(status: 'pending').order(:send_at).first
    next_message.send_at.to_time.change(sec: 0) if next_message.present? && next_message.send_at.present?
  end

  def first_sent_at
    first_message_sent = message_recipients.where.not(sent_at: nil).order(:sent_at).first
    first_message_sent.sent_at.to_time.change(usec: 0) if first_message_sent.present?
  end

  def last_sent_at
    last_message_sent = message_recipients.where.not(sent_at: nil).order(:sent_at).last
    last_sent_at = last_message_sent.sent_at if last_message_sent.present?
    last_sent_at ||= Time.now
    last_sent_at.to_time.change(usec: 0)
  end

  def send_duration
    unless first_sent_at.present?
      return {
        "years": 0, "months": 0, "weeks": 0, "days": 0, "hours": 0, "minutes": 0, "seconds": 0
      }
    end
    TimeDifference.between(first_sent_at, last_sent_at).in_general
  end

  def send_duration_readable
    return 'Message not sent yet' unless first_sent_at.present?
    return 'Immediate' if first_sent_at == last_sent_at

    TimeDifference.between(first_sent_at, last_sent_at).humanize
  end

  def recipients
    all_recipients = message_recipients # .as_json(only: %i[id recipient grouping platform sent_at status])

    groups = all_recipients.reject { |g| g['grouping'].nil? }.uniq { |g| g['grouping'] }.count
    group_list = all_recipients.reject { |g| g['grouping'].nil? }.uniq { |g| g['grouping'] }.collect { |g| g['grouping'] }
    individuals = all_recipients.count { |i| i['grouping'].nil? }
    status = Hash[all_recipients.group_by(&:status).map { |k, v| [k, v.size] }]
    status['total'] = all_recipients.count
    results = {
      'status' => status,
      'group_count' => groups,
      'group_list' => group_list,
      'individual_count' => individuals,
      'list' => (individuals == 1 ? all_recipients.as_json(only: %i[id recipient name grouping platform send_at sent_at status response]) : [])
    }

    results
  end

  def recipients_full
    all_recipients = message_recipients # .as_json(only: %i[id recipient grouping platform sent_at status])

    groups = all_recipients.reject { |g| g['grouping'].nil? }.uniq { |g| g['grouping'] }.count
    group_list = all_recipients.reject { |g| g['grouping'].nil? }.uniq { |g| g['grouping'] }.collect { |g| g['grouping'] }
    individuals = all_recipients.count { |i| i['grouping'].nil? }
    status = Hash[all_recipients.group_by(&:status).map { |k, v| [k, v.size] }]
    status['total'] = all_recipients.count
    results = {
      'status' => status,
      'group_count' => groups,
      'group_list' => group_list,
      'individual_count' => individuals,
      'list' => all_recipients.as_json(only: %i[id recipient name grouping platform send_at sent_at status response])
    }

    results
  end

  def sender
    result = nil
    if self[:sender].present?
      result = self[:sender][0...self[:sender].index(':')]
    else
      # find the platform for the recipients
      if message_recipients.first.platform.present?
        # v2 style platform
        platform = message_recipients.first.platform
      elsif message_recipients.first.platform_id.present?
        # v3+ style platform
        platform = Platform.find(message_recipients.first.platform_id).name
      end
      user = User.find(user_id)
      result = platform == 'SMS' ? user.sms_number.number : user.primary_twitter_profile.screen_name
    end

    result
  end

  def current_status
    # NOTE: status is a calculated field based on the individual messages
    current_status = status
    unless current_status == 'Deleted' || current_status == 'Archived' # || 'Draft'
      recipient_statuses = message_recipients.select(:status, :send_at)
      #   # current_status = Hash[recipients.group_by(&:itself).map { |k, v| [k, v.size] }]
      #   # current_status['total'] = recipients.count
      #
      # Possible updatable states are: Pending, In Progress, Sent, Error, Cancelled
      current_status = if recipient_statuses.any? { |r| r.status == 'cancelled' } then 'Cancelled'
                       elsif recipient_statuses.all? { |r| r.status == 'sent' } then 'Sent'
                       elsif recipient_statuses.any? { |r| r.status == 'in progress' } || (recipient_statuses.any? { |r| r.status == 'pending' }) && recipient_statuses.any? { |r| r.send_at <= Time.now } then 'In Progress'
                       elsif recipient_statuses.any? { |r| r.status == 'error' } then 'Error'
                       elsif recipient_statuses.all? { |r| r.status == 'pending' } || recipient_statuses.all? { |r| r.send_at >= Time.now } then 'Pending'
      end
    end
    update_attributes!(status: current_status)
    current_status
  end

  def as_json(options = {})
    super(options).merge(id: to_param)
  end
end
