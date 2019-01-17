class CommitOfferMailer < ApplicationMailer
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  default from: 'info@stackedsports.com'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.commit_offer_mailer.daily_email.subject
  #
  def daily_email
    mail(to: 'john.henderson@stackedsports.com,ben@stackedsports.com', subject: 'Recruit Suite Daily Offer & Commit Tweets')
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.commit_offer_mailer.weekly_email.subject
  #
  def weekly_email
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
