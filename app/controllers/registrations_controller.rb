class RegistrationsController < AuthController
  before_action :allow_public?
  allow_unauthenticated_access
  layout "public"
  before_action :identify_token

  def new
    @user = User.new(user_params)
  end

  def create
    @user = User.new(user_params)
    @user.prefered_language = I18n.locale
    if @user.save
      unless multi_account?
        @user.account_user = AccountUser.create(account: Account.first, role: Role.find_by(name: 'Inactive'))
      end
      start_new_session_for @user
      redirect_to root_path, notice: t('controllers.registrations.signed_up')
    else
      render :new, status: :unprocessable_entity, notice: t('controllers.registrations.sign_up_failed')
    end
  end

  private

  def identify_token
    session[:invite_id] = nil if params[:invite_token]
    logger.debug "Validate if registration is public".green
    return true # if Rails.configuration.license['registration'][:allow_public] == true || session[:invite_id]

    logger.debug "Registration is invite only, do we have a valid invite token?".green
    redirect_to errors_e403_invite_path and return unless params[:invite_token]

    @invite = Invite.find_by_token_for(:invite, params[:invite_token])
    redirect_to errors_e403_invite_path and return unless @invite

    # logger.debug "Invite found in identify_token: #{@invite.inspect}".light_green
    # session[:invite_id] = @invite.id if @invite
  end

  def user_params
    unless params[:user].present?
      return {}
    end
    params.require(:user).permit(:email_address, :password, :password_confirmation, :invitation_token, :prefered_language)
  end
end