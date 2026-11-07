class Member::TeamUsersController < Member::MemberController
  
  def create
    @team = Current.teams.find(params[:team_user][:team_id])
    @team_user = @team.team_users.new(team_user_params)
    @team_user.role = "member" if @team_user.role.nil?

    if @team_user.save
      render turbo_stream: [
        turbo_stream.replace("team_members_#{@team.id}", partial: "member/teams/members", locals: { item: @team })
      ]
    end
  end

  def update
    @user_role = TeamUser.find(params[:id])
    
    if @user_role.update(team_user_params)
      flash.now[:notice] = "Rôle mis à jour"
      logger.info "Updated role for TeamUser ##{@user_role.id}: #{team_user_params[:role]}"
      render turbo_stream: [
        turbo_stream.replace("role_field_#{@user_role.id}", partial: "member/team_users/role", locals: { user_role: @user_role })
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @team_user = TeamUser.find(params[:id])
    @team = @team_user.team
    @team_user.destroy
    render turbo_stream: [
      turbo_stream.replace("team_members_#{@team.id}", partial: "member/teams/members", locals: { item: @team })
    ]
  end

  private

  def team_user_params
    params.require(:team_user).permit(:role, :user_id, :team_id)
  end

  def set_item
    @item = TeamUser.find(params[:id])
  end
end
