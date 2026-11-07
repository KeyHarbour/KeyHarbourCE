class TrustAssetMailer < ApplicationMailer
  default from: 'no-reply@keyharbour.ca'

  def reminders
    @user = params[:user]
    @account = params[:account]
    attachments.inline['harbor-42.png'] = File.read(Rails.root.join('app/assets/images/harbor-42.png'))
    logger.debug "Preparing to send trust asset reminder email to #{@user.email_address} for account #{@account.name}"
    mail(to: @user.email_address, subject: "Rappel : Vos actifs de confiance pour #{@account.name} expirent bientôt")
  end
end
