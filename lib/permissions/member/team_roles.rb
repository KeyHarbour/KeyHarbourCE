class Permissions::Member::TeamRoles < Permissions::Member::Base
  def index?
    user.account_admin?
  end

  def show?
    user.account_admin?
  end

  def new?
    user.account_admin?
  end

  def edit?
    user.account_admin?
  end

  def update?
    user.account_admin?
  end

  def create?
    user.account_admin?
  end

  def destroy?
    user.account_admin?
  end    
end
