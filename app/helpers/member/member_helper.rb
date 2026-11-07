module Member::MemberHelper
  def breadcrumbs
    [ controller_items[:"member/dashboard"].merge(path: member_root_path, only_icon: true) ]
  end

  def index_page_name
    t("activerecord.models.#{controller_name.singularize}").pluralize
  end

  def new_page_name
    t("member.#{controller_name}.new.page_title")
  end

  def edit_page_name
    t("member.#{controller_name}.edit.page_title")
  end

  def create_button_text
    t("member.#{controller_name}.create")
  end

  def trust_icon(size, value = nil)
    icon_tag = icon(ApplicationHelper::CONTROLLERS[:"member/trust_assets"][:icon], class: "#{size}")
    return icon_tag if value.nil?
    icon_tag + " " + value.to_s
  end

  def key_icon(size, value = nil)
    icon_tag = icon(ApplicationHelper::CONTROLLERS[:"member/key_value_stores"][:icon], class: "#{size}")
    return icon_tag if value.nil?
    icon_tag + " " + value.to_s
  end

  def tf_icon(size, value = nil)
    icon_tag = icon(ApplicationHelper::CONTROLLERS[:"member/statefiles"][:icon], class: "#{size}")
    return icon_tag if value.nil?
    icon_tag + " " + value.to_s
  end

  def license_icon(size, value = nil)
    icon_tag = icon(ApplicationHelper::CONTROLLERS[:"member/license/applications"][:icon], class: "#{size}")
    return icon_tag if value.nil?
    icon_tag + " " + value.to_s
  end
end