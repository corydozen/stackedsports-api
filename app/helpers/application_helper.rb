module ApplicationHelper
  def flash_class(level)
    case level
    when 'notice' then 'is-info'
    when 'success' then 'is-success'
    when 'error' then 'is-danger'
    when 'alert' then 'is-warning'
    end
  end

  def greeting
    time = Time.now.in_time_zone('Central Time (US & Canada)')
    current_time = time.to_i
    midnight = time.beginning_of_day.to_i
    noon = time.middle_of_day.to_i
    five_pm = time.change(hour: 17).to_i
    eight_pm = time.change(hour: 20).to_i

    result = if midnight.upto(noon).include?(current_time)
               'Good Morning'
             elsif noon.upto(five_pm).include?(current_time)
               'Good Afternoon'
             elsif five_pm.upto(eight_pm).include?(current_time)
               'Good Evening'
             elsif eight_pm.upto(midnight + 1.day).include?(current_time)
               'Good Night'
    end

    result
  end

  def self.random_string(length = 10)
    o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
    string = (0...length).map { o[rand(o.length)] }.join
  end

  def self.hour_24_to_12(hour_24)
    hour_12 = hour_24 - 12

    if hour_12 == 0
      return '12 pm'
    elsif hour_12 == -12
      return '12 am'
    elsif hour_12 > 0
      return "#{hour_12} pm"
    elsif hour_12 < 0
      return "#{hour_24} am"
    end
  end

  def is_admin_page
    current_page?(dashboard_path) || request.fullpath.include?('admin') ? true : false
  end

  def is_login_page
    current_page?(login_path) || current_page?(request_access_path) || current_page?(password_resets_path) || current_page?(reset_password_path) || current_page?(success_path)
  end

  def is_athletes_page
    current_page?(root_path) || request.original_url.include?('athletes')
  end

  def is_messages_page
    request.original_url.include?('messages')
  end

  def is_media_page
    current_page?(media_path) || (@medium && current_page?(controller: 'media', action: 'edit'))
  end
end
