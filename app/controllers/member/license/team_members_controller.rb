class Member::License::TeamMembersController < Member::License::LicenseController
  def index
    @item = datum.new
    @employees = Current.account.app_team_members.all
    logger.debug "Employess: #{@employees.count}".red
  end

  def create
    Current.account.app_team_members.destroy_all
    upload = Current.account.app_team_members.new()
    upload.import_file = item_params[:import_file]
    redirect_to back_path, notice: I18n.t("controllers.license_team_members.successful_imported")
  end

  def datum
    Current.account.app_team_members
  end

  def datum_name
    "team_member"
  end
  
  def back_path
    member_license_team_members_path()
  end

  private
  
    def set_item
      @item = datum.find_by(id: params[:id])
    end

    def item_params
      return {} unless params[:license_team_member].present?
      params.expect(license_team_member: [ :import_file ])
    end
end


