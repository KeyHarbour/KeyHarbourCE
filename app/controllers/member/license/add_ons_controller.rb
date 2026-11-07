class Member::License::AddOnsController < Member::License::InstancesController
  before_action :set_instance
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
    @instance.add_ons
  end

  def datum_name
    "instance"
  end
  
  def back_path
    member_license_application_instances_path(@application)
  end

  private
    def set_instance
      if params[:id]
        @add_on = Current.add_ons.find_by(id: params[:id]) if params[:id].present?
        @instance = @add_on.instance
        @application = @instance.application
      else
        @instance = Current.app_instances.find_by(id: params[:instance_id]) if params[:instance_id].present?
        @application = @instance.application
      end
    end
  
    def set_item
      @item = Current.add_ons.find_by(id: params[:id])
      @instance = @item.instance if @item.present?
      @application = @instance.application
    end

    def item_params
      return {} unless params[:license_add_on].present?
      params.expect(license_add_on: [ :name, :uuid, :description, :active, :unit_cost, :instance_id ])
    end
end


