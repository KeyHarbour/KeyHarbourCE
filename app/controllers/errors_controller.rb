class ErrorsController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :enforce_custom_permissions!
  
  layout "errors"

  def e403_invite
    render status: :forbidden
  end

  def e403
    render status: :forbidden
  end

  def feature403
    render status: :forbidden
  end
end
