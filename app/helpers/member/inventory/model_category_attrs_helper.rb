module Member::Inventory::ModelCategoryAttrsHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/inventory/model_category_attrs", member_inventory_model_category_attrs_path(@model_category), @item&.name, @model_category.id )
    result
  end

  def add_button(position)
    controller_items[:'member/inventory/model_category_attrs'].merge(path: new_item_url, title:  new_name(@item)) if position == :top and action_name == 'index'
  end

  def search
    false
  end

  def index_page_name
    t("activerecord.models.#{controller_name.singularize}").pluralize
  end

  def new_page_name
    t("member.#{controller_name}.new.page_title")
  end

  def new_item_url
    new_member_inventory_model_category_attr_path(@model_category)
  end

  def form_url
    return member_inventory_model_category_attrs_path(@model_category) if @item.new_record?
    member_inventory_attr_path(@item, locale: I18n.locale)
  end
end
