class Permissions::Member::Dashboard < Permissions::Member::Base
  def index?
    true
  end
end