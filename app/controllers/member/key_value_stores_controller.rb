class Member::KeyValueStoresController < Member::WorkspacesController
  before_action :key_value?

  def datum
    @workspace.key_value_stores.where(environment: @environment)
  end

  def index
    @item = datum.new(item_params)

    query = params[:key_value_store]&.[](:key).presence || "*"
    logger.debug "Search query: #{query}".green

    filter = []
    filter << "environment_id = #{@environment.id} "
    filter << "one_time_only = '#{@item.one_time_only}' " unless @item.one_time_only.blank?
    filter << "private = '#{@item.private}' " unless @item.private.blank?

    logger.debug filter
    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'key' ],
      filter: filter.join(" AND ")
    }
    @pagy, @items = pagy(datum.search(query, search_options), limit: 10)
  end

  def datum_name
    "Key/Value"
  end
  
  def back_path
    member_workspace_key_value_stores_path(@item.workspace, environment: @item.environment.name)
  end

  private
    def set_items
      set_item if params[:id]
      @workspace = Current.workspaces.find_by(uuid: params[:workspace_id]) if params[:workspace_id]

      if params[:key_value_store] && params[:key_value_store][:environment_id]
        @environment = @workspace.project.environments.find_by(id: params[:key_value_store][:environment_id])
      else
        @environment = @workspace.project.environments.find_by(name: params[:environment]) if params[:environment]
        @environment = @workspace.project.environments.find_by(name: params[:key_value_store][:environment]) if params.dig(:key_value_store, :environment)
      end
      super
    end

    def item_params
      unless params[:key_value_store].present?
        return {}
      end
      params.expect(key_value_store: [ :key, :value, :expires_at, :environment_id, :private, :one_time_only ])
    end

    def set_item
      @item = KeyValueStore.find_by(id: params[:id])
      @key_value_store = @item
      @environment = @item.environment
      @workspace = @item.workspace
    end

    def key_value?
      KeyHarbour.key_value?
    end
end