class Permissions::Admin::ProcessedDates < Permissions::Admin::Dashboard
  def destroy?
    user.admin?
  end
end
