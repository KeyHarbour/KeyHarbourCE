module Member::License::LicenseesHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/license/licensees", member_license_instance_licensees_path(@instance), @item&.uuid, @item&.id )
    result
  end

  def index_page_name
    "Licensees"
  end

  def search
    false
  end


  def add_button(position)
    controller_items[:'member/license/licensees'].merge(path: new_item_url, title:  new_name(@item)) if position == :top and action_name == 'index'
  end

  def new_item_url
    new_member_license_instance_licensee_path
  end

  def form_url    
    return member_license_instance_licensees_path(@instance, locale: I18n.locale) if @item.new_record?
    member_license_instance_licensee_path(@item, locale: I18n.locale)
  end
end
