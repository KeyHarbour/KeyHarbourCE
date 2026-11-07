class SessionsController < AuthController
  allow_unauthenticated_access only: %i[ new create omniauth ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: t('controllers.sessions.rate_limit') }
  layout "public"
  
  def new
    redirect_to new_registration_path if User.count == 0
  end

  def omniauth
    logger.debug "XXXXX".green
    auth = request.env['omniauth.auth']
    user = User.from_omniauth(auth)

    if user.persisted?
      user.update(last_access_at: DateTime.now)
      start_new_session_for user
      redirect_to after_authentication_url, notice: t('controllers.sessions.oauth_success')
    else
      redirect_to new_session_path, alert: t('controllers.sessions.oauth_failure')
    end
  end

  def create
    if user = User.authenticate_by(params.require(:session).permit(:email_address, :password))
      user.update(last_access_at: DateTime.now)
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: t('controllers.sessions.login_failure')
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
