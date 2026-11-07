class Member::Wizard::KeyValues::KeyValuesController < Member::MemberController
  def new_organization
    @organization = Current.account.organizations.new
    @organization.environments.build(name: "Production")
    @organization.environments.build(name: "Dev")
    render 'member/wizard/new_organization'
  end

  def create_organization
    @organization = Current.account.organizations.new(organization_params)
    @organization.environments.each do |env|
      @organization.environments.delete(env) if env.name.blank?
    end    
    if @organization.save
      @project = @organization.projects.build
      render 'member/wizard/new_project'
    else
      @organization.environments.build if @organization.environments.blank?
      render 'member/wizard/new_organization', status: :unprocessable_entity
    end
  end

  def create_project
    @organization = Current.account.organizations.find(params[:organization_id])
    @project = @organization.projects.build(project_params)
    if @project.save
      @project.environments = @organization.environments
      @workspace = @project.workspaces.build
      render 'member/wizard/new_workspace'
    else
      render 'member/wizard/new_project', status: :unprocessable_entity
    end
  end

  def create_workspace
    @project = Current.account.projects.find(params[:project_id])
    @workspace = @project.workspaces.build(workspace_params)
    if @workspace.save
      redirect_to member_workspace_key_value_stores_path(@workspace, environment: @project.environments.first.name), notice: "Félicitations ! Votre espace est prêt. Vous etes dans votre espace de statefile pour votre environment #{@project.environments.first.name}"
    else
      render 'member/wizard/new_workspace', status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, 
      environments_attributes: [ :id, :name, :_destroy ]
    )
  end

  def project_params
    params.require(:project).permit(:name)
  end

  def workspace_params
    params.require(:workspace).permit(:name)
  end

  private
  
  def set_breadcrumbs
    set_organization_breadcrumbs
    @breadcrumbs << { name: t('wizard.organizations'), path: member_wizard_statefiles_new_organization_path }

    @breadcrumbs << { name: t('wizard.organizations'), path: member_wizard_statefiles_new_organization_path }
  end
  
  def item_params
    unless params[:statefile].present?
      return {}
    end
    params.expect(statefile: [ :uuid, :pretty_content ])
  end
end