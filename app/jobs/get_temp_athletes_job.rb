class GetTempAthletesJob < ApplicationJob
  queue_as :default

  def perform(_scheduled_time)
    # start_time = Time.now
    # rsaths = RsAthlete.all
    # rsaths_array = rsaths.to_a.delete_if { |a| a[:twitterProfile].nil? || a[:twitterProfile] == '' }
    #
    # athlete_ocurrences = rsaths_array.group_by { |a| a[:twitterProfile]['screenName'] }.map { |k, v| [k, v.size] }.to_h
    #
    # rsaths.each do |rsath|
    #   # TODO: Update to use import...
    #   next unless rsath.twitterProfile.present? && rsath.twitterProfile['screenName'].present?
    #
    #   ta = TempAthlete.where('lower(twitter_handle) = ?', rsath.twitterProfile['screenName'].downcase).first_or_create(twitter_handle: rsath.twitterProfile['screenName'].downcase)
    #   next unless ta.present?
    #
    #   # So if we got this far, we have either found or created a temp athlete, so now we need to check if his data needs to be updated
    #   ta.grad_year = rsath.grad_year if rsath.grad_year.present? && !ta.grad_year.present?
    #   ta.positions = rsath.positions if rsath.positions.present? && !ta.positions.present?
    #   name_array = rsath.name.split(' ') if rsath.name.present?
    #   if name_array.present?
    #     # p "Name Array info: #{name_array}"
    #     ta.first_name = name_array[0] unless ta.first_name.present?
    #     # Shifting array to get the rest of name as last name
    #     name_array.shift
    #     ta.last_name = name_array.join(' ') if !ta.last_name.present? && name_array.present? # this will be empty if there were no spaces in the name
    #   end
    #   # ta.address = rsath.address if rsath.address.present? && !ta.address.present?
    #   # ta.state = rsath.state if rsath.state.present? && !ta.state.present?
    #   # ta.city = rsath.city if rsath.city.present? && !ta.city.present?
    #   # ta.zip_code = rsath.zip_code if rsath.zip_code.present? && !ta.zip_code.present?
    #   ta.mobile = rsath.phone if rsath.phone.present? && !ta.mobile.present?
    #   ta.email = rsath.email if rsath.email.present? && !ta.email.present?
    #   ta.hs_name = rsath.high_school if rsath.high_school.present? && !ta.hs_name.present?
    #   # ta.hs_state = rsath.hs_state if rsath.hs_state.present? && !ta.hs_state.present?
    #   ta.priority = athlete_ocurrences[ta.twitter_handle] if athlete_ocurrences[ta.twitter_handle].present? && ta.priority != athlete_ocurrences[ta.twitter_handle]
    #   next unless ta.changed?
    #
    #   # The model has been updated so print some output and save the record
    #   p "Updating #{ta.first_name} #{ta.last_name} - @#{ta.twitter_handle} with ID: #{ta.id}, the following fields were changed: #{ta.changes}"
    #   ta.save!
    # end
    # end_time = Time.now
    #
    # p "Began Updating Temp Athletes at #{start_time}, finished process at #{end_time}, total duration: #{TimeDifference.between(start_time, end_time).humanize}"
  end
end
