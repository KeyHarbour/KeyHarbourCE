class Member::Inventory::InstancesController < Member::Inventory::InventoryController
  include Pagy::Method

  def index
    @instance = Inventory::Instance.new(item_params)
    @item = @instance
    # @organization.instances
    query = params[:inventory_instance]&.[](:name).presence || "*"  
    where_clause = "organization_id = #{@organization.id}"

    if @instance.workspace_ids.present? && @instance.workspace_ids.compact_blank.count > 0
      where_clause += " AND workspace_id IN #{@instance.workspace_ids.compact_blank.map(&:to_i)}"
    end

    if @instance.environment_ids.present? && @instance.environment_ids.compact_blank.count > 0
      where_clause += " AND environment_id IN #{@instance.environment_ids.compact_blank.map(&:to_i)}"
    end

    if @instance.model_category_ids.present? && @instance.model_category_ids.compact_blank.count > 0
      where_clause += " AND model_category_id IN #{@instance.model_category_ids.compact_blank.map(&:to_i)}"
    end

    if @instance.model_family_ids.present? && @instance.model_family_ids.compact_blank.count > 0
      where_clause += " AND model_family_id IN #{@instance.model_family_ids.compact_blank.map(&:to_i)}"
    end

    sort_direction = params[:direction] || "asc"
    @pagy, @items = pagy(
      Inventory::Instance.search(query, {
        filter: where_clause,
        attributes_to_highlight: [ "name" ]
      }),
      items: 20
    )    
  end

  def export
    @instances = @organization.instances.includes(:instance_attrs)

    respond_to do |format|
      format.json do
        # On définit le nom du fichier pour le téléchargement
        response.headers['Content-Disposition'] = "attachment; filename=\"#{@organization.name}-#{Date.today}.json\""
        # Rails cherchera automatiquement le fichier : app/views/votre_controller/export.json.jbuilder
        render :export 
      end
    end    
    # json_data = render_to_string(json: @organization.instances.as_json(only: [:name, :uuid, :status]))
    # send_data json_data, 
    #           filename: "#{@organization.name}-#{Date.today}.json", 
    #           type: :json
  end

  def datum
    @organization.instances
  end

  def datum_name
    "instance"
  end
  
  def back_path
    member_organization_instances_path(@organization)
  end

  private
    def item_params
      unless params[:inventory_instance].present?
        return {}
      end
      params.expect(inventory_instance: [ :name, :status, environment_ids: [], model_category_ids: [], workspace_ids: [], model_family_ids: [] ])
    end
end
