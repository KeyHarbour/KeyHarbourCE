# Preview all emails at http://localhost:3000/rails/mailers/trust_asset_mailer
class TrustAssetMailerPreview < ActionMailer::Preview
  def reminders
    TrustAssetMailer.with(user: User.first || User.new(name: "Test", email_address: "test@example.com")).reminders
  end
end
