class Member::License::ApplicationsController < Member::License::LicenseController
  def index
    @item = datum.build(item_params)
    @query = @item.name || '*'

    filter = []
    filter << "account_id = #{Current.account.id} "
    filter << "renewal_level = #{params[:license_application][:renewal].last} " if params[:license_application].present? and params[:license_application][:renewal].present? and params[:license_application][:renewal].last.present?

    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ],
      filter: filter.join(" AND ")
    }

    @pagy, @items = pagy(License::Application.search(@query, search_options), limit: 10)
    # logger.debug @query
    # logger.debug search_options
    # logger.debug "Pagy: #{@pagy.inspect}"
    # logger.debug @items.count
  end

  def show
  end

  def datum
    Current.account.applications.active
  end

  def datum_name
    "application"
  end
  
  def back_path
    member_license_applications_path()
  end

  private
  
    def set_item
      @item = Current.applications.find_by(id: params[:id])
      @application = @item if @item.present?
      # @organization = @item.organization if @item.present?
    end

    def item_params
      return {} unless params[:license_application].present?
      params.expect(license_application: [ :name, :short_name, :owner, :renewal, :renewal_date, :data, :status, :organization_id, :vendor, :tier, :seats, :uuid, :unit_cost, :logo, :alert_renewal_2, :alert_renewal_1, :alert_seats_2, :alert_seats_1 ])
    end
end


