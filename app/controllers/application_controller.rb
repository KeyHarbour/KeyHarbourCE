class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method
  helper_method :allow_public?
  # helper_method :oauth_google?
  # helper_method :oauth_microsoft?
  # helper_method :oauth_github?
  # helper_method :key_value?
  helper_method :multi_account?
  # helper_method :tf_statefile?
  # helper_method :trust_assets?
  before_action :check_password_change
  before_action :set_locale
  before_action { Pagy::I18n.locale = I18n.locale }
  before_action :set_items
  before_action :set_organization
  before_action :set_parent_obj
  # before_action :set_project
  # before_action :set_workspace
  before_action :validate_organization, unless: :except_organization_controller?
  before_action :set_parent_item
  before_action :set_item, only: %i[ edit update destroy show]
  before_action :enforce_custom_permissions!
  before_action :set_breadcrumbs
  before_action :log_history
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  layout "application"
  
  helper_method :back_path
  helper_method :datum_name
  helper_method :current_user

  def except_organization_controller?
    self.class.in?(%w[OrganizationsController])
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def validate_organization
    # logger.debug Current.user.email_address
    # if Current.account.organization.nil?
    #   redirect_to new_organization_path
    # end
  end

  def index
    @pagy, @items = pagy(datum.all)
  end

  def show
    # @item = datum.find(params[:id])
  end

  def edit
  end
  
  def new
    @item = datum.new
    logger.debug @item.to_json
  end

  def create
    @item = datum.new(item_params)
    if @item.save     
      redirect_to back_path, notice: "#{datum_name.capitalize} #{t('globals.created')}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    logger.debug "Update".green
    if @item.update(item_params)
      redirect_to back_path, notice: "#{datum_name.capitalize} #{t('globals.updated')}."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @item.respond_to?(:status) 
      @item.archived!
      @item = nil
    else
      @item.destroy!
    end
    redirect_to back_path, status: :see_other, notice: "#{datum_name.capitalize} #{t('globals.destroyed')}."
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

  def set_breadcrumb_actions
    # @breadcrumbs << { name: "All" } if action_name.to_sym == :index
    @breadcrumbs << { name: t('globals.new') } if %i[create new].include?(action_name.to_sym)
    @breadcrumbs << { name: t('globals.update') } if %i[edit update].include?(action_name.to_sym)
    # @breadcrumbs << { name: "Details" } if %i[show].include?(action_name.to_sym)
  end

  def set_locale
    I18n.locale = params[:locale] || (Current.user ? Current.user.prefered_language : I18n.default_locale)
    # logger.debug "Locale set to '#{I18n.locale}'".red
  end

  def default_url_options
    { locale: I18n.locale }
  end
  
  def set_item
    return unless respond_to?(:datum)

    @item = datum.find(params.expect(:id))
  end

  def set_parent_item; end

  def set_breadcrumbs; end

  def back_path; end

  def set_parent_obj; end

  def set_items; end

  def set_organization; end
  
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

  # def key_value?
  #   logger.debug "Key Value: #{KeyHarbour.key_value?}".light_blue
  #   redirect_to errors_feature403_path, alert: t('controllers.member.license_denied') and return unless KeyHarbour.key_value?
  #   true
  # end

  def multi_account?
    logger.debug "Multi Account: #{KeyHarbour.multi_account?}".light_blue
    redirect_to errors_feature403_path and return unless KeyHarbour.multi_account?
    true
  end

  # def tf_statefile?
  #   logger.debug "TF Statefile: #{KeyHarbour.tf_statefile?}".light_blue
  #   redirect_to errors_feature403_path and return unless KeyHarbour.tf_statefile?
  #   true
  # end

  # def trust_assets?
  #   logger.debug "Trust assets: #{KeyHarbour.trust_assets?}".light_blue
  #   redirect_to errors_feature403_path and return unless KeyHarbour.trust_assets?
  #   true
  # end

  # def license?
  #   logger.debug "License: #{KeyHarbour.license?}".light_blue
  #   redirect_to errors_feature403_path, alert: t('controllers.member.license_denied') and return unless KeyHarbour.license?
  #   true
  # end

  def enforce_custom_permissions!
    guard = UserPermissionService.new(Current.user, params[:controller], action_name, @organization, @project, @workspace)
    return if guard.allowed?
    
    redirect_to errors_feature403_path, alert: t('permission_denied')
  end
end
