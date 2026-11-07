class Member::StatefilesController < Member::WorkspacesController
  # before_action :tf_statefile?

  def datum
    @workspace.statefiles.where(environment: @environment)
  end

  def edit
    @field = params[:field]
  end

  def update
    if @item.update(item_params)
      respond_to do |format|
        format.html { redirect_to member_statefile_path(@item, environment: @environment.name), notice: "Mis à jour avec succès." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def index
    @item = datum.new(item_params)
    @pagy, @items = pagy(datum, limit: 10)
  end

  def datum_name
    "statefile"
  end

  def duplicate
    copy = @statefile.dup
    copy.uuid += " - Copy"
    my_count = @workspace.statefiles.where(uuid: copy.uuid, environment: @environment).count
    copy.uuid += "(#{my_count})" if my_count >= 1
    copy.save

    redirect_to member_workspace_statefiles_path(@item.workspace, environment: @item.environment.name)
  end

  def push
    @item.update(published_at: DateTime.now)

    redirect_to member_workspace_statefiles_path(@item.workspace, environment: @item.environment.name)
  end
  
  def back_path
    member_workspace_statefiles_path(@item.workspace, environment: @item.environment.name)
  end

  def instance
    set_item
    resource_index = params[:resource].to_i
    instance_index = params[:instance].to_i
    content = @item.parsed_content
    content["resources"][resource_index]["instances"].delete_at(instance_index)
    if content["resources"][resource_index]["instances"].empty?
      content["resources"].delete_at(resource_index)
    end
    @item.content = JSON.pretty_generate(content)
    @item.save
    redirect_to member_statefile_path(@item)
  end

  private

    def set_items
      set_item if params[:id]
      @workspace = Current.workspaces.find_by(uuid: params[:workspace_id]) if params[:workspace_id]

      if params[:statefile] && params[:statefile][:environment_id]
        @environment = @workspace.project.environments.find_by(id: params[:statefile][:environment_id])
      else
        @environment = @workspace.project.environments.find_by(name: params[:environment]) if params[:environment]
      end
      super
    end

    def item_params
      unless params[:statefile].present?
        return {}
      end
      params.expect(statefile: [ :uuid, :pretty_content ])
    end

    def set_item
      @item = Statefile.find_by(id: params[:id])
      @statefile = @item
      @environment = @item.environment
      @workspace = @item.workspace
    end
end