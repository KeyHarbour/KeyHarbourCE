class Member::License::LicenseesController < Member::License::InstancesController
  def index
    @item = License::Licensee.new
    @licensees = License::Licensee.tree(@instance)
    @licensees = License::Licensee.calculate_total_costs(@licensees)
  end

  def create
    upload = @instance.licensees.new()
    upload.import_file = item_params[:import_file]
    redirect_to back_path, notice: I18n.t("controllers.license_licensees.licensees_successful_imported")
  end

  def datum
    @instance.licensees
  end

  def datum_name
    "licensee"
  end
  
  def back_path
    member_license_instance_licensees_path(@instance)
  end

  private

    def set_organization
      @instance = Current.app_instances.find_by(id: params[:instance_id]) if params[:instance_id].present?
      @application = @instance.application
    end
  
    def set_item
      @item = Current.app_instances.find_by(id: params[:id])
      @instance = @item.instance if @item.present?
    end

    def item_params
      return {} unless params[:license_licensee].present?
      params.expect(license_licensee: [ :import_file ])
    end
end


