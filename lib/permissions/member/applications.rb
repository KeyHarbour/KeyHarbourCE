class Permissions::Member::Applications < Permissions::Member::Base
  def index?
    true
  end

  def show?
    true
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
