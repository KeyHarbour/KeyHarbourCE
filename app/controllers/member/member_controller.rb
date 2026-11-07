class Member::MemberController < ApplicationController
  before_action :check_role
  before_action :record_permissions
  before_action :validate_account

  def set_organization_breadcrumbs
    @breadcrumbs ||= []
    # @breadcrumbs << { name: t('globals.dashboard'), path: member_root_path }
    @breadcrumbs << { name: t('activerecord.models.organization').pluralize, path: member_organizations_path } unless [ "teams", "users" ].include?(controller_name) || @organization.nil?  
    @breadcrumbs << { name: @organization.name, path: member_organization_path(@organization) } unless @organization.nil?
  end
  
  def set_breadcrumbs
    set_organization_breadcrumbs
    @breadcrumbs << { name: t('activerecord.models.project').pluralize, path: member_organization_projects_path(@organization) } if controller_name == "projects" || !@project.nil?
    @breadcrumbs << { name: @project.name, path: member_project_path(@project) } unless @project.nil?
    @breadcrumbs << { name: t('activerecord.models.team').pluralize, path: member_teams_path(@organization) } if controller_name == "teams" || !@team.nil?
    @breadcrumbs << { name: @team.name, path: member_team_path(@team) } unless @team.nil?
    @breadcrumbs << { name: t('activerecord.models.user').pluralize, path: member_users_path } if controller_name == "users" || !@user.nil?
    @breadcrumbs << { name: @user.email_address, path: member_user_path(@user) } unless @user.nil?
    # @breadcrumbs << { name: t('activerecord.models.invite').pluralize, path: member_organization_invites_path(@organization) } if controller_name == "invites" || !@invite.nil?
    @breadcrumbs << { name: @invite.email, path: member_organization_invite_path(@organization, @invite) } unless @invite.nil?


    @breadcrumbs << { name: t('activerecord.models.workspace').pluralize, path: member_project_workspaces_path(@project) } if controller_name == "workspaces" || !@workspace.nil?
    # @breadcrumbs << { name: @workspace.name, path: member_workspace_path(@workspace) } unless @workspace.nil?

    # @breadcrumbs << { name: "Environments", path: member_organization_environments_path(@organization) } if controller_name == "environments" || !@environment.nil?
    # @breadcrumbs << { name: @environment.name, path: member_environment_path(@environment) } unless @environment.nil?

    @breadcrumbs << { name: t('activerecord.models.statefile').pluralize, path: member_project_workspaces_path(@project) } if controller_name == "statefiles" || !@statefile.nil?
    @breadcrumbs << { name: @statefile.uuid, path: member_statefile_path(@statefile) } unless @statefile.nil?    

    # @breadcrumbs << { name: t('globals.pricing'), path: member_pricings_path() } if controller_name == "pricings"

    if controller_name == "tokens" || !@token.nil?
      @breadcrumbs << { name: t('activerecord.models.token').pluralize, path: member_project_tokens_path(@project) } if @project
      @breadcrumbs << { name: t('activerecord.models.token').pluralize, path: member_organization_tokens_path(@organization) } if @organization
    end

    @breadcrumbs << { name: t('globals.subscription'), path: '' } if controller_name == "subscriptions"

    set_breadcrumb_actions
  end

  def convert_to_meili_filter(hash)
    hash.map { |k, v| "#{k} = '#{v}'" }.join(" AND ")
  end

  private
  
  def set_item
    @item = datum.find_by(name: params[:id])
  end

  def validate_account
    return if Current.user&.admin?

    logger.debug "Current User got account"
    if Current.user.account.nil?
      if controller_name != 'accounts'
        redirect_to new_member_account_path # , alert: t('member.member_controller.account_required')
      end
    elsif Current.account.uncompleted? && ![ 'pricings', 'subscriptions', 'subscription_coupons' ].include?(controller_name)
      redirect_to member_pricings_path
    end
  end

  def validate_admin?
    return true if Current.user.global_role == :admin
    return true if [ "Admin", "Owner" ].include?(Current.user.account_user&.role&.name)

    logger.debug "Access denied for user #{Current.user.email_address} with role #{Current.user.account_user&.role&.name}".red
    redirect_to(member_errors_e403_path, alert: t('member.member_controller.access_denied'))
  end

  def record_permissions
    Rails.configuration.permission_service.get(controller_name, action_name, [ Current.role ])
  end

  def check_role
    logger.debug "Check role for user #{ Current.user && Current.user.email_address} with role #{Current.user && Current.role&.name}".green
    logger.debug "Validate account".green
    if User.all.count == 1
      logger.debug "Setting first user as admin".green
      first_admin = User.first
      first_admin.global_role = :admin
      first_admin.save!
    end
    logger.debug "Current user: #{Current.user.email_address} with role #{Current.role&.name}".green
    if Current.user.account_user&.role&.name == "Inactive"
      redirect_to errors_e403_path, alert: t('member.member_controller.access_denied')
    end
    true
  end
end