class Member::ProjectsController < Member::OrganizationsController
  def new
    super()
    @item.environments = @organization.environments.all if controller_name == 'projects'
  end

  def index
    @item = datum.new(item_params)
    @query = @item.name || '*'

    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ]
    }

    @pagy, @items = pagy(datum.search(@query, search_options), limit: 10)
    if controller_name == 'projects'
      render "member/organizations/projects"
    end
  end

  def create
    if controller_name == 'projects'
      @item = datum.new(item_params)
      # @item.uuid = SecureRandom.uuid
      if @item.save
        redirect_to member_project_path(@item), notice: "#{datum_name.capitalize} was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    else
      super
    end
  end

  def show
    if controller_name == 'projects'
      @pagy, @projects = pagy(@organization.projects)
      @project = @item
    else
      super
    end
  end
  
  def back_path
    return member_organization_projects_path(@organization, locale: I18n.locale) if !@item || @item.new_record?
    member_project_path(@item, locale: I18n.locale)
  end

  def datum
    @organization.projects.not_archived
  end

  def datum_name
    t('activerecord.models.project')
  end


  private
  def set_items
    super && return if controller_name == 'projects'

    if params[:project_id]
      @project = Current.projects.find_by(uuid: params[:project_id])
    else
      set_item
      @project = @item.project
    end
    @organization = @project.organization
  end

  def set_item
    if controller_name == 'projects'
      @item = Project.find_by!(uuid: params[:id])
      @project = @item
      @organization = @project.organization
    else
      super()
    end
  end

  def item_params
    return {} unless params[:project].present?

    params.expect(project: [ :name, :description, :status, environment_ids: [], admin_ids: [], contributor_ids: [], reader_ids: [] ])
  end
end