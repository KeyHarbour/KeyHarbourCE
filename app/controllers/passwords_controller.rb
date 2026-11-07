class PasswordsController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :enforce_custom_permissions!
  
  before_action :set_user_by_token, only: %i[ edit update ]
  layout "public"

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: t('.instructions_sent')
  end

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.update(password_change_required: false)
      redirect_to new_session_path, notice: t('.password_updated')
    else
      redirect_to edit_password_path(params[:token]), alert: t('.did_not_match')
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: t('passwords.invalid_or_expired')
    end
end
