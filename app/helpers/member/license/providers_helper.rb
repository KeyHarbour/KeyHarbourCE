module Member::License::ProvidersHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/license/providers", member_license_providers_path, @item&.name, @item&.id )
    result
  end

  def search
    true
  end

  def add_button(position)
    controller_items[:'member/license/providers'].merge(path: new_item_url, title: new_name(@item)) if position == :top and action_name == 'index'
  end

  # def display_back
  #   true
  # end

  # # def page_title
  # #   I18n.t("menu.instances", name: @application.name)
  # # end

  def new_item_url
    new_member_license_provider_path
  end

  def form_url    
    return member_license_providers_path(locale: I18n.locale) if @item.new_record?
    member_license_provider_path(@item, locale: I18n.locale)
  end
end
