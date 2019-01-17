class AdminController < ApplicationController
  def index
    @current_users = User.where.not(last_activity_at: nil)
                         .where(last_logout_at: nil)
                         .or(User.where('last_activity_at > last_logout_at'))
    # .where("#{config.last_activity_at_attribute_name} > ? ", config.activity_timeout.seconds.ago.utc.to_s(:db))
  end
end
