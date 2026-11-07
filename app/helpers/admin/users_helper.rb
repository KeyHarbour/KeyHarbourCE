module Admin::UsersHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"admin/users", admin_users_path, "", "" )
    result
  end

  def new_item_url
    nil
  end

  def display_back
    true
  end

  def back_path
    admin_accounts_path
  end

  def index_page_name
    "Users for account '#{Current.account.name}'"
  end

  def edit_page_name
    "Edit existing organization"
  end

  def form_url
    return admin_users_path if @item.new_record?
    admin_user_path(@item)
  end

  def search
    true
  end
end
