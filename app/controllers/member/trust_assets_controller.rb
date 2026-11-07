class Member::TrustAssetsController < Member::WorkspacesController
  before_action :trust_assets?



  def create
    @item = datum.new(item_params)
    @item.update_expiry
    if @item.save     
      redirect_to back_path, notice: "#{datum_name.capitalize} #{t('globals.created')}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params)
      @item.update_expiry
      @item.save
      redirect_to back_path, notice: "#{datum_name.capitalize} #{t('globals.updated')}."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def datum
    @workspace.trust_assets.where(environment: @environment)
  end

  def index
    @item = datum.new(item_params)
    @workspace.fix_cost(environment: @environment)

    query = params[:trust_asset]&.[](:name).presence || "*"
    logger.debug "Search query: #{query}".green

    filter = []
    filter << "environment_id = #{@environment.id} "
    filter << "issuer = '#{@item.issuer}' " unless @item.issuer.blank?
    filter << "consumer = '#{@item.consumer}' " unless @item.consumer.blank?
    filter << "format = '#{@item.format}' " unless @item.format.blank?


    logger.debug filter
    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ],
      filter: filter.join(" AND ")
    }
    @pagy, @items = pagy(datum.search(query, search_options), limit: 10)
  end
  
  def back_path
    member_workspace_trust_assets_path(@item.workspace, environment: @environment.name)
  end

  private
    def set_items
      set_item if params[:id]
      @workspace = Current.workspaces.find_by(uuid: params[:workspace_id]) if params[:workspace_id]

      if params[:trust_asset] && params[:trust_asset][:environment_id]
        @environment = @workspace.project.environments.find_by(id: params[:trust_asset][:environment_id])
      else
        @environment = @workspace.project.environments.find_by(name: params[:environment]) if params[:environment]
        @environment = @workspace.project.environments.find_by(name: params[:trust_asset][:environment]) if params.dig(:trust_asset, :environment)
      end
      super
    end

    def item_params
      unless params[:trust_asset].present?
        return {}
      end
      params.expect(trust_asset: [ :name, :issuer, :expires_at, :environment_id, :format, :consumer, :description, :reminder_days ])
    end

    def set_item
      @item = TrustAsset.find_by(id: params[:id])
      @key_value_store = @item
      @environment = @item.environment
      @workspace = @item.workspace
    end

    def trust_assets?
      KeyHarbour.trust_assets?
    end
end