class Admin::AdminController < ApplicationController
  before_action :authenticate_admin!

  def authenticate_admin!
    logger.debug "Current User: #{Current.user&.email_address} with role #{Current.user&.global_role}"
    unless Current.user&.admin?
      redirect_to root_path, alert: t('controllers.admin.unauthorized')
    end
  end

  def set_breadcrumbs
    @breadcrumbs ||= []
    @breadcrumbs << { name: "Admin Dashboard", path: admin_root_path }
    # @breadcrumbs << { name: "Organizations", path: member_organizations_path }
    # @breadcrumbs << { name: @organization.name, path: member_organization_path(@organization) } unless @organization.nil?
    # @breadcrumbs << { name: "Projects", path: member_organization_projects_path(@organization) } if controller_name == "projects"
    # @breadcrumbs << { name: @project.name, path: member_organization_project_path(@organization, @project) } unless @project.nil?
    # @breadcrumbs << { name: "Environments", path: member_organization_environments_path(@organization) } if controller_name == "environments"
    # @breadcrumbs << { name: "Workspaces", path: member_organization_project_workspaces_path(@organization, @project) } if controller_name == "workspaces"
    # @breadcrumbs << { name: "Tokens", path: member_organization_tokens_path(@organization) } if controller_name == "tokens"    

    set_breadcrumb_actions
  end
end