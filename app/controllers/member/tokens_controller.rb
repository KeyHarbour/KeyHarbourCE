class Member::TokensController < Member::ProjectsController
  def create
    if params[:token_project][:scopable_type] == "Project"
      @item = @project.token_projects.new(item_params)
    else
      @workspace = @project.workspaces.find(params[:token_project][:workspace_id])
      @item = @workspace.token_workspaces.new(item_params)
    end
    if @item.save
      @pagy, @items = pagy(datum.all)
      render turbo_stream: turbo_stream.update("form_to_replace", partial: "create", locals: { item: @item, items: @items, pagy: @pagy })
    else
      render :new, status: :unprocessable_entity
    end
  end

  def datum
    @project.token_projects
  end

  def new
    @item = datum.new(scopable: @project)
  end

  def show
    redirect_to back_path
  end

  def index
    @item = datum.build(item_params)
    @query = @item.name || '*'
    filter = []
    filter << "environment_id = #{@item.environment.id} " if @item.environment
    logger.debug filter
    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ],
      filter: filter.join(" AND ")
    }
    @pagy, @items = pagy(datum.search(@query, search_options), limit: 10)
  end

  def datum_name
    "token"
  end
  
  def back_path
    member_project_tokens_path(@project)
  end

  def destroy
    @item = Token.find(params[:id])
    @project = @item.scopable
    @item.destroy!
    redirect_to back_path, status: :see_other, notice: "#{datum_name.capitalize} was successfully destroyed."
  end

  private
    def set_items
      @project = Current.projects.find_by(uuid: params[:project_id])
      @organization = @project.organization
    end

    def set_item
      @item = TokenProject.find(params[:id])
      @project = @item.scopable
    end

    def item_params
      return {} unless params[:token_project].present?

      params.expect(token_project: [ :name, :expiration, :only_project, :scopable_type, :scopable_id, :environment_id ])
    end
end