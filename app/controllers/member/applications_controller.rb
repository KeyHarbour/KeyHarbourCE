class Member::ApplicationsController < Member::MemberController
  before_action :validate_licence

  def validate_licence
    redirect_to member_errors_e403_path if Rails.configuration.register.feature(:license) == false
  end

  def index
  end
end


