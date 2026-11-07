module Member::Inventory::ModelCategoriesHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/inventory/model_categories", member_organization_inventory_model_categories_path(@organization), @item&.name, @organization.id )
    result
  end

  def add_button(position)
    controller_items[:'member/inventory/model_categories'].merge(path: new_item_url, title:  new_name(@item)) if position == :top and action_name == 'index'
  end

  def search
    true
  end

  def new_item_url
    new_member_organization_inventory_model_category_path(@organization)
  end

  def form_url
    return member_organization_inventory_model_categories_path(@organization) if @item.new_record?
    member_inventory_model_category_path(@item, locale: I18n.locale)
  end
end
