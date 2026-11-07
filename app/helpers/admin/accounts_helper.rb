module Admin::AccountsHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"admin/accounts", admin_accounts_path, "", "" )
    result
  end

  def search
    true
  end

  def new_item_url
    nil
  end

  def index_page_name
    "Accounts"
  end

  def new_page_name
    "New account"
  end

  def edit_page_name
    "Edit existing account"
  end

  def form_url
    return admin_accounts_path(locale: I18n.locale) if @item.new_record?
    admin_account_path(@item, locale: I18n.locale)
  end
end
