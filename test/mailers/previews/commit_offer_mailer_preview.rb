# Preview all emails at http://localhost:3000/rails/mailers/commit_offer_mailer
class CommitOfferMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/commit_offer_mailer/daily_email
  def daily_email
    CommitOfferMailer.daily_email
  end

  # Preview this email at http://localhost:3000/rails/mailers/commit_offer_mailer/weekly_email
  def weekly_email
    CommitOfferMailer.weekly_email
  end

end
