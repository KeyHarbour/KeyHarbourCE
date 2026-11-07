class Permissions::Admin::Dashboard < Permissions::Member::Base
  def index?
    user.admin?
  end
end
