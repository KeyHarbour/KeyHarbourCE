module Member::License::QuotesHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/license/quotes", member_license_application_quotes_path(@application), @item&.uuid, @item&.id )  
    result
  end

  def search
    true
  end

  def add_button(position)
    return controller_items[:'member/license/quotes'].merge(path: new_item_url, title: new_name(@item)) if position == :top and action_name == 'index'
    controller_items[:'member/license/quotes'].merge(path: member_license_application_quotes_path(@application), title: I18n.t("globals.back")) if position == :top and action_name == 'show'
  end

  def page_title
    I18n.t("menu.quotes")
  end

  def new_item_url
    new_member_license_application_quote_path(@application)
  end

  def form_url    
    return member_license_application_quotes_path(@application, locale: I18n.locale) if @item.new_record?
    member_license_quote_path(@item, locale: I18n.locale)
  end
end
