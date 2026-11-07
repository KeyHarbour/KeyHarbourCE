module Member::Inventory::ModelFamiliesHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/inventory/model_families", member_organization_inventory_model_families_path(@organization), @item&.name, @organization.id )
    result
  end

  def add_button(position)
    controller_items[:'member/inventory/model_families'].merge(path: new_item_url, title:  new_name(@item)) if position == :top and action_name == 'index'
  end

  def new_item_url
    new_member_organization_inventory_model_family_path(@organization)
  end

  def form_url
    return member_organization_inventory_model_families_path(@organization) if @item.new_record?
    member_inventory_model_family_path(@item, locale: I18n.locale)
  end
end
