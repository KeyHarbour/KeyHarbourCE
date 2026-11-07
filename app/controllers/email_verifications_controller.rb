class EmailVerificationsController < ApplicationController
  before_action :set_email_change_by_token, only: %i[ edit ]

  def create
    if EmailChange.where(user: Current.user, confirmed_at: nil, created_at: 1.day.ago..).exists?
      redirect_to settings_info_path, alert: t(".please_wait")
    else
      Current.user.initiate_email_verification
      redirect_to settings_info_path, notice: t(".notice", email_address: Current.user.email_address)
    end
  end

  def edit
    return redirect_to root_path, alert: t('.unauthorize') if Current.user != @email_change.user
    return redirect_to root_path, alert: t(".already_confirmed") if @email_change.confirmed_at?

    if Current.user.update email_verified: true
      @email_change.update confirmed_at: Time.zone.now
      redirect_to user_path(Current.user), notice: t(".success")
    else
      redirect_to user_path(Current.user), alert: t(".failed")
    end
  end

  private

  def set_email_change_by_token
    @email_change = EmailChange.find_by_token_for!(:email_change, params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    redirect_to new_settings_email_path, alert: t("email_verifications.invalid_or_expired")
  end
end

