class Member::WorkspacesController < Member::ProjectsController
  def update
    if turbo_frame_request?
      @field = params[:field]
      respond_to do |format|
        if @item.update(item_params)
          format.html { redirect_to member_workspace_path(@item), notice: t('controllers.member.workspaces.updated') }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    else
      super()
    end
  end

  def index
    @item = datum.new(item_params)
    @query = @item.name || '*'

    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ]
    }
    @pagy, @items = pagy(datum.search(@query, search_options), limit: 10)
  end
  
  def activate
    @item.update(status: 'active')
    redirect_back(fallback_location: root_path) 
  end

  def unactivate
    @item.update(status: 'disabled')
    redirect_back(fallback_location: root_path) 
  end

  def show
    # @workspace.create_statefiles
    super
  end

  def datum
    @project.workspaces.not_archived.current_user(Current)
  end

  def datum_name
    "workspace"
  end
  
  def back_path
    member_project_workspaces_path(@project)
  end

  private

  def set_items
    super && return if controller_name == 'workspaces'

    if params[:workspace_id]
      @workspace = Current.workspaces.find_by(uuid: params[:workspace_id])
    else
      set_item
      @workspace = @item.workspace
    end
    @project = @workspace.project
    @organization = @project.organization
  end

  def item_params
    return {} unless params[:workspace].present?

    params.expect(workspace: [ :name, :uuid, :status, :description ])
  end

  def set_item
    @item = Workspace.find_by(uuid: params[:id])
    logger.debug "action_name: #{action_name}"
    @workspace = @item
    @project = @workspace.project
  end
end