module Member::EnvironmentsHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/environments", member_organization_environments_path(@organization), @item&.name, @item&.id )
    result
  end

  def add_button(position)
    controller_items[:'member/environments'].merge(path: new_item_url, title: new_name(@item)) if position == :top and action_name == 'index'
  end

  def search
    true
  end

  def new_item_url
    new_member_organization_environment_path
  end

  def form_url    
    return member_organization_environments_path(@organization, locale: I18n.locale) if @item.new_record?
    member_environment_path(@item, locale: I18n.locale)
  end
end
