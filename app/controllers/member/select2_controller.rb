class Member::Select2Controller < Member::MemberController
  def workspace_ids
    organization = Current.organizations.find_by(uuid: params[:organization_id])
    workspaces = organization.workspaces.order(:name)
    render json: workspaces.map { |workspace| { id: workspace.id, name: workspace.name } }
  end

  def environment_ids
    organization = Current.organizations.find_by(uuid: params[:organization_id])
    environments = organization.environments.order(:name)
    render json: environments.map { |environment| { id: environment.id, name: environment.name } }
  end

  def model_category_ids
    organization = Current.organizations.find_by(uuid: params[:organization_id])
    model_categories = organization.model_categories.order(:name)
    render json: model_categories.map { |model_category| { id: model_category.id, name: model_category.name } }
  end  

  def model_family_ids
    organization = Current.organizations.find_by(uuid: params[:organization_id])
    model_families = organization.model_families.order(:name)
    render json: model_families.map { |model_family| { id: model_family.id, name: model_family.name } }
  end 
end