module Member::AccountsHelper
  def new_page_name
    t('member.accounts.new.title')
  end
  
  def new_name(item)
    I18n.t("globals.new") + " "
  end

  def new_item_url
    new_member_account_path
  end

  def form_url
    return member_accounts_path(locale: I18n.locale) if @item.new_record?
    member_account_path(@item, locale: I18n.locale)
  end

  def menu
    []
  end
end
