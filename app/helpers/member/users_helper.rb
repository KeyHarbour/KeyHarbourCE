module Member::UsersHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/users", member_users_path, @item&.name, @item&.id )
    result
  end

  def search
    true
  end

  def display_back
    true
  end

  def new_item_url
    new_member_user_path()
  end

  def form_url
    return member_users_path(locale: I18n.locale) if @item.new_record?
    member_user_path(@item, locale: I18n.locale)
  end
end
