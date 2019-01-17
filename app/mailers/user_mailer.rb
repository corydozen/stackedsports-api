# NOTE: https://stackoverflow.com/questions/39204047/rails-mailer-previews-not-available-from-spec-mailers-previews
# For previewing emails

class UserMailer < ApplicationMailer
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  default from: 'info@stackedsports.com'
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_needed_email.subject
  #
  def activation_needed_email(user)
    @user = user
    token = @user.activation_token
    raise 'Activation token not found' unless token.present?
    @url = activate_user_url(id: token)
    mail(to: @user.email, subject: 'Welcome to RecruitSuite')
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_success_email.subject
  #
  def activation_success_email(user)
    @user = user

    @env = case ENV['ENVIRONMENT']
           when 'dev'
             'http://localhost:3000'
           when 'test'
             'https://recruit-suite-web-staging.herokuapp.com'
           when 'prod'
             'https://app.recruitsuite.co'
           else
             'https://app.recruitsuite.co'
           end
    @url  = "#{@env}/login"
    mail(to: @user.email, subject: 'Your RecruitSuite account is now activated')
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #
  def reset_password_email(user)
    @user = user
    token = @user.reset_password_token
    raise 'Password Reset token not found' unless token.present?
    @url = edit_password_reset_url(id: token)
    mail(to: @user.email, subject: 'RecruitSuite password reset request')
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.magic_login_email.subject
  #
  def magic_login_email(user)
    @greeting = 'Hi'

    mail to: 'to@example.org'
  end
end
