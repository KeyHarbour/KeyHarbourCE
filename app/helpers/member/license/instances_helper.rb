module Member::License::InstancesHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/license/instances", member_license_application_instances_path(@application), @application&.name, @application&.id )
    result[-1][:title] = I18n.t("menu.instances", name: @application&.name)
    result
  end

  def display_back
    true
  end

  def page_title
    I18n.t("menu.instances", name: @application.name)
  end

  def new_item_url
    new_member_license_application_instance_path(@application)
  end

  def form_url    
    return member_license_application_instances_path(@application, locale: I18n.locale) if @item.new_record?
    member_license_instance_path(@item, locale: I18n.locale)
  end

  def top_buttons
    return [] unless action_name == "index"
    [
      {
        name: index_page_name.capitalize,
        link: new_member_license_application_instance_path(@application),
        icon: "ki-filled ki-plus"
      }
    ]
  end

  def bg_color_usage_rate(item)
    return bg_color(0) if item.usage_rate || 0 > 1
    return bg_color(1) if item.usage_rate || 0  > (item.alert_seats_2 || item.application.alert_seats_2)
    return bg_color(2) if item.usage_rate || 0 > (item.alert_seats_1 || item.application.alert_seats_1)
    bg_color(3)
  end
end
