
class UserMailerPreview < ActionMailer::Preview
  def activation_needed_email
    UserMailer.activation_needed_email(User.first)
  end

  def activation_success_email
    UserMailer.activation_success_email(User.first)
  end

  def reset_password_email
    UserMailer.reset_password_email(User.first)
  end
end
