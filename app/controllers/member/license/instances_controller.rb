class Member::License::InstancesController < Member::License::ApplicationsController
  def index
    @item = datum.build(item_params)
    @query = @item.name || '*'

    filter = []
    filter << "application_id = #{@application.id} "

    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ],
      filter: filter.join(" AND ")
    }

    @pagy, @items = pagy(License::Instance.search(@query, search_options), limit: 10)
    logger.debug @query
    logger.debug search_options
    logger.debug "Pagy: #{@pagy.inspect}"
    logger.debug @items.count
  end
    
  def datum
    Current.account.app_instances.active
  end

  def datum_name
    "instance"
  end
  
  def back_path
    member_license_application_instances_path(@application)
  end

  private
    def set_parent_obj
      if params[:id]
        @item = Current.add_ons.find_by(id: params[:id]) if params[:id].present?
        @instance = @item.instance
        @application = @instance.application
      else
        @application = Current.applications.find_by(id: params[:application_id]) if params[:application_id].present?
      end
    end
  
    def set_item
      @item = Current.app_instances.find_by(id: params[:id])
      @application = @item.application if @item.present?
    end

    def item_params
      return {} unless params[:license_instance].present?
      params.expect(license_instance: [ :name, :short_name, :owner, :renewal_date, :data, :status, :application_id, :seats, :uuid, :unit_cost, :logo, :alert_renewal_2, :alert_renewal_1, :alert_seats_2, :alert_seats_1 ])
    end
end


