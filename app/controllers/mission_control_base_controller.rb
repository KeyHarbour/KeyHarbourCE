class MissionControlBaseController < ApplicationController
  before_action :authenticate_admin!
  skip_before_action :enforce_custom_permissions!

  def authenticate_admin!
    logger.debug "Current User: #{Current.user&.email_address} with role #{Current.user&.global_role}"
    unless Current.user&.admin?
      redirect_to root_path, alert: t('controllers.admin.unauthorized')
    end
  end
end
