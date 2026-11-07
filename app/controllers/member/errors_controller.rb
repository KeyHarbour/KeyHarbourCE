class Member::ErrorsController < ApplicationController
  allow_unauthenticated_access
  layout "errors"

  def e403_member
    render status: :forbidden
  end
end
