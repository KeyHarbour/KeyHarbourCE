module Member::OrganizationsHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/organizations", member_organizations_path, @organization&.name, @organization&.uuid )
    result
  end

  def add_button(position)
    controller_items[:'member/organizations'].merge(path: new_item_url, title:  new_name(@item)) if position == :top and action_name == 'index'
  end

  def search
    true
  end

  def new_item_url
    new_member_organization_path
  end

  def form_url
    return member_organizations_path(locale: I18n.locale) if @item.new_record?
    member_organization_path(@item, locale: I18n.locale)
  end
end
