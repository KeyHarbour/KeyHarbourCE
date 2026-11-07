class Member::License::QuotesController < Member::License::ApplicationsController
  def index
    @item = datum.build(item_params)
    @query = @item.uuid || '*'

    filter = []
    filter << "application_id = #{@application.id} "

    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'uuid' ],
      filter: filter.join(" AND ")
    }

    @pagy, @items = pagy(License::Quote.search(@query, search_options), limit: 10)
  end

  def show
    @quote_application = @item.quote_applications.where(application_id: @application).first_or_create do |quote_application|
      quote_application.seats = @application.seats
    end
    @application.app_instances.each do |instance|
      logger.debug "App instance: #{instance.name}"
      quote_instance = instance.quote_instances.where(quote_application: @quote_application).first_or_create do |_quote_instance|
        _quote_instance.seats = @application.seats
      end
      instance.add_ons.each do |add_on|
        quote_add_one = add_on.quote_add_ons.where(quote_instance: quote_instance).first_or_create
      end
    end
  end

  def compare
    @quotes = @application.quotes.where(id: params[:ids])
  end

  def datum
    @application.quotes
  end

  def datum_name
    "quote"
  end
  
  def back_path
    member_license_application_quotes_path(@application)
  end

  private
    def set_parent_obj
      if params[:id]
        @item = Current.quotes.find_by(id: params[:id]) if params[:id].present?
        @application = @item.application
      else
        @application = Current.applications.find_by(id: params[:application_id]) if params[:application_id].present?
      end
    end
  
    def set_item
      @item = Current.quotes.find_by(id: params[:id])
      @application = @item.application if @item.present?
    end

    def item_params
      return {} unless params[:license_quote].present?
      params.expect(license_quote: [ :uuid, :status, :available_on, :available_until, :approved_at, :status, :application_id, :provider_id ])
    end  
end