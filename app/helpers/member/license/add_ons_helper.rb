module Member::License::AddOnsHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/license/add_ons", member_license_instance_add_ons_path(@instance), @item&.name, @item&.id )
    result
  end

  def display_back
    true
  end

  # def page_title
  #   I18n.t("menu.instances", name: @application.name)
  # end

  def new_item_url
    new_member_license_instance_add_on_path(@instance)
  end

  def form_url    
    return member_license_instance_add_ons_path(@instance, locale: I18n.locale) if @item.new_record?
    member_license_add_on_path(@item, locale: I18n.locale)
  end

  def top_buttons
    return [] unless action_name == "index"
    [
      {
        name: index_page_name.capitalize,
        link: new_member_license_instance_add_on_path(@instance),
        icon: "ki-filled ki-plus"
      }
    ]
  end
end
