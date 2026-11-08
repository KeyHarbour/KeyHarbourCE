class Member::License::LicenseController < Member::AccountsController
  before_action :validate_licence

  def validate_licence
    KeyHarbour.license?
  end

  private
    def set_breadcrumbs
      set_organization_breadcrumbs
      @breadcrumbs << { name: t('activerecord.models.license_application').pluralize, path: member_license_applications_path } if [ "applications", "instances", "licensees" ].include?(controller_name)
      @breadcrumbs << { name: @application.short_name, path: member_license_application_instances_path(@application) } unless @application.nil?

      @breadcrumbs << { name: t('activerecord.models.license_instance').pluralize, path: member_license_application_instances_path(@application) } if [ "instances" ].include?(controller_name)
      @breadcrumbs << { name: @instance.short_name, path: member_license_instance_licensees_path(@instance) } unless @instance.nil?

      @breadcrumbs << { name: t('activerecord.models.license_licensee').pluralize, path: member_license_instance_licensees_path(@instance) } if controller_name == "licensees"

      @breadcrumbs << { name: t('activerecord.models.license_team_member').pluralize, path: member_license_team_members_path } if controller_name == "team_members"

      set_breadcrumb_actions
    end

    def set_organization
      @instance = Current.app_instances.find_by(id: params[:instance_id]) if params[:instance_id].present?
      @application = Current.applications.find_by(id: params[:application_id]) if params[:application_id].present? && !@application.present?
      # @organization = @application.organization if @application.present? && !@organization.present?
      # @organization = Current.organizations.find_by(uuid: params[:organization_id]) unless @organization.present?
    end
  
    def set_item
      @item = datum.find_by(name: params[:id])
    end
end