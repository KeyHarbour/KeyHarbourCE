class Member::StatefileTagsController < Member::WorkspacesController
  def datum
    @statefile.statefile_tag
  end

  def new
    @item = @statefile.build_statefile_tag()
  end

  def create
    @item = @statefile.build_statefile_tag(item_params)
    if @item.save
      @pagy, @items = pagy(@workspace.statefiles.where(environment: @environment), limit: 10)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to back_path }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @item = StatefileTag.find_by(id: params[:id])
    @item.destroy

    redirect_to member_workspace_statefiles_path(@workspace, environment: @environment.name)
  end
  
  def back_path
    # return member_workspace_statefiles_path(@workspace, locale: I18n.locale) if !@item || @item.new_record?
    member_workspace_statefiles_path(@statefile.workspace, environment: @statefile.environment.name)
  end

  private
    def set_breadcrumb_actions
    end

    def item_params
      params.expect(statefile_tag: [ :tag ])
    end

    def set_items
      @item = StatefileTag.find_by(id: params[:id]) if params[:id]
      @statefile = Statefile.find_by(id: params[:statefile_id]) if params[:statefile_id]
      logger.debug "Statefile: #{@statefile.inspect}"
      @statefile = @item.statefile if @item
      @workspace = @statefile.workspace
      @project = @workspace.project
      @environment = @statefile.environment
      @organization = @project.organization
    end

    def set_item
      
      
    end
end