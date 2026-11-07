class Member::Inventory::ModelCategoriesController < Member::Inventory::InventoryController
  def index
    @item = datum.new(item_params)

    query = params[:inventory_model_category]&.[](:name).presence || "*"
    logger.debug "Search query: #{query}".green

    filter = []
    filter << "resource_type = #{@item.resource_type} " unless @item.resource_type.blank?
    filter << "model_family_id = #{@item.model_family.id} " unless @item.model_family.blank?
    # filter << "one_time_only = '#{@item.one_time_only}' " unless @item.one_time_only.blank?
    # filter << "private = '#{@item.private}' " unless @item.private.blank?

    logger.debug filter
    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'key' ],
      filter: filter.join(" AND ")
    }
    @pagy, @items = pagy(datum.search(query, search_options), limit: 10)
  end

  def datum
    @organization.model_categories
  end

  def datum_name
    "model_categorie"
  end
  
  def back_path
    member_organization_inventory_model_categories_path(@organization)
  end

  private
    def item_params
      unless params[:inventory_model_category].present?
        return {}
      end
      params.expect(inventory_model_category: [ :name, :model_family_id, :resource_type, :active, model_family_ids: [] ])
    end
  
    def set_item
      @item = Current.account.model_categories.find_by(id: params[:id])
      @organization = @item.organization
    end
end
