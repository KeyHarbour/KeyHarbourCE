class Member::TeamRolesController < Member::MemberController
  
  def create
    @team = Current.teams.find(params[:team_role][:team_id])
    @team_role = @team.team_roles.new(team_role_params)
    @team_role.role = "viewer" if @team_role.role.nil?

    if @team_role.save
      resource_type = @team_role.resource_type
      partial_name = resource_type.downcase.pluralize
  
      render turbo_stream: turbo_stream.replace(
        "team_#{partial_name}_#{@team.id}",
        partial: "member/teams/#{partial_name}",
        locals: { 
          item: @team, 
          items: @team.team_roles.where(resource_type: resource_type) 
        }
      )
    end
  end

  def update
    @team_role = TeamRole.find(params[:id])
    
    if @team_role.update(team_role_params)
      flash.now[:notice] = "Rôle mis à jour"
      logger.info "Updated role for TeamRole ##{@team_role.id}: #{team_role_params[:role]}"
      render turbo_stream: [
        turbo_stream.replace("team_role_field_#{@team_role.id}", partial: "member/team_roles/role", locals: { team_role: @team_role })
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @team_role = TeamRole.find(params[:id])
    resource_type = @team_role.resource_type
    partial_name = resource_type.downcase.pluralize
    @team = @team_role.team
    @team_role.destroy

    render turbo_stream: turbo_stream.replace(
      "team_#{partial_name}_#{@team.id}",
      partial: "member/teams/#{partial_name}",
      locals: { 
        item: @team, 
        items: @team.team_roles.where(resource_type: resource_type) 
      }
    )
  end

  private

  def team_role_params
    params.require(:team_role).permit(:organization_id, :project_id, :workspace_id, :team_id, :role)
  end

  def set_item
    @item = TeamRole.find(params[:id])
  end
end
