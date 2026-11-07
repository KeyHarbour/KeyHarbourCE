class Member::Inventory::ModelFamiliesController < Member::Inventory::InstancesController
  def index
    @item = datum.new(item_params)

    query = params[:inventory_model_family]&.[](:key).presence || "*"
    logger.debug "Search query: #{query}".green

    filter = []
    # filter << "environment_id = #{@environment.id} "
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
    @organization.model_families
  end

  def datum_name
    "model_family"
  end
  
  def back_path
    member_organization_inventory_model_families_path(@organization)
  end

  private
    def item_params
      unless params[:inventory_model_family].present?
        return {}
      end
      params.expect(inventory_model_family: [ :name, :organization_id ])
    end
  
    def set_item
      @item = Current.account.model_families.find_by(id: params[:id])
      @organization = @item.organization
    end
end
