module Member::License::ApplicationsHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/license/applications", member_license_applications_path, @application&.name, @application&.id )
    # result += breadcrumbs_restfull( :"member/license/applications", member_license_applications_path, @application&.name, @application&.id )
    result
  end

  def search
    true
  end

  def bg_progress_color(usage_rate)
    if usage_rate < 0.7
      "bg-info-lt"
    elsif usage_rate < 0.9
      "bg-success-lt"
    elsif usage_rate < 1
      "bg-warning-lt"
    else
      "bg-danger-lt"
    end
  end

  def add_button(position)
    controller_items[:'member/license/applications'].merge(path: new_item_url, title:  new_name(@item)) if position == :top and action_name == 'index'
  end

  def index_page_name
    "Application"
  end

  def new_item_url
    new_member_license_application_path
  end

  def form_url    
    return member_license_applications_path(locale: I18n.locale) if @item.new_record?
    member_license_application_path(@item, locale: I18n.locale)
  end
end
