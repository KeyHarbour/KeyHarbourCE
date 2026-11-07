class Permissions::Member::Teams < Permissions::Member::Base
  def index?
    KeyHarbour.multi_team? && user.account_admin?
  end

  def show?
    KeyHarbour.multi_team? && user.account_admin?
  end

  def new?
    KeyHarbour.multi_team? && user.account_admin?
  end

  def edit?
    KeyHarbour.multi_team? && user.account_admin?
  end

  def update?
    KeyHarbour.multi_team? && user.account_admin?
  end

  def create?
    KeyHarbour.multi_team? && user.account_admin?
  end

  def destroy?
    KeyHarbour.multi_team? && user.account_admin?
  end  
end
