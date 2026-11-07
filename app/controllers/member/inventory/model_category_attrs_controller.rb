class Member::Inventory::ModelCategoryAttrsController < Member::Inventory::ModelCategoriesController
  def index
    @item = datum.new(item_params)

    query = params[:inventory_model_category_attr]&.[](:name).presence || "*"
    logger.debug "Search query: #{query}".green

    filter = []
    # filter << "resource_type = #{@item.resource_type} " unless @item.resource_type.blank?
    # filter << "model_family_id = #{@item.model_family.id} " unless @item.model_family.blank?
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
    @model_category.model_category_attrs
  end

  def datum_name
    "model_category_attr"
  end
  
  def back_path
    member_inventory_model_category_attrs_path(@model_category)
  end

  private

    def set_items
      if params[:model_category_id].present?
        @model_category = Current.account.model_categories.find_by(id: params[:model_category_id])
      else
        @item = Current.account.model_category_attrs.find_by(id: params[:id])
        @model_category = @item.model_category
      end
      @organization = @model_category.organization
    end

    def item_params
      unless params[:inventory_model_category_attr].present?
        return {}
      end
      params.expect(inventory_model_category_attr: [ :name, :attr_name, :active ])
    end
  
    def set_item
      @item = @model_category.model_category_attrs.find_by(id: params[:id])
    end
end
