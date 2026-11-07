class AuthController < ActionController::Base
  include Authentication
  include Pagy::Method
  helper_method :allow_public?
  # helper_method :oauth_google?
  # helper_method :oauth_microsoft?
  # helper_method :oauth_github?
  helper_method :multi_account?
  before_action :check_password_change
  before_action :set_locale
  before_action { Pagy::I18n.locale = I18n.locale }
  before_action :log_history
  allow_browser versions: :modern
  layout "public"

  helper_method :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  private

  def check_password_change
    # if authenticated? && !Current.user
    #   reset_session # Efface complètement le contenu de la session courante
    #   cookies.clear # Supprime tous les cookies du domaine
    #   render json: { status: "Session et cookies nettoyés avec succès !" }    
    # end
    if authenticated? && Current.user && Current.user.password_change_required?
      allowed_pages = (controller_name == "users" && action_name.in?([ "edit", "update" ]))

      is_logout = (controller_name == "sessions" && action_name == "destroy")

      unless allowed_pages || is_logout
        redirect_to edit_user_path(Current.user), alert: t('controllers.application.password_change_required')
      end
    end
  end

  def set_locale
    I18n.locale = params[:locale] || (Current.user ? Current.user.prefered_language : I18n.default_locale)
    # logger.debug "Locale set to '#{I18n.locale}'".red
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def log_history
    return unless Current.user.present? && @organization.present?

    ActionLog.create!(
      user_id: Current.user.id,
      organization_id: @organization.id,
      controller: params[:controller],
      action: params[:action],
      action_id: @item&.id,
      method_type: request.method
    )
  end

  def allow_public?
    logger.debug "Allow Public: #{KeyHarbour.allow_public?}".light_blue
    redirect_to errors_feature403_path and return unless KeyHarbour.allow_public?
    true
  end

  # def oauth_github?
  #   logger.debug "Google Oauth: #{KeyHarbour.oauth_github?}".light_blue
  #   redirect_to errors_feature403_path and return unless KeyHarbour.oauth_github?
  #   true
  # end

  # def oauth_microsoft?
  #   logger.debug "Google Oauth: #{KeyHarbour.oauth_microsoft?}".light_blue
  #   redirect_to errors_feature403_path and return unless KeyHarbour.oauth_microsoft?
  #   true
  # end

  # def oauth_google?
  #   logger.debug "Google Oauth: #{KeyHarbour.oauth_google?}".light_blue
  #   redirect_to errors_feature403_path and return unless KeyHarbour.oauth_google?
  #   true
  # end

  def multi_account?
    logger.debug "Multi Account: #{KeyHarbour.multi_account?}".light_blue
    redirect_to errors_feature403_path and return unless KeyHarbour.multi_account?
    true
  end
end
