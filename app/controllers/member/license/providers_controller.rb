class Member::License::ProvidersController < Member::License::LicenseController
  def index
    @item = datum.build(item_params)
    @query = @item.name || '*'

    filter = []
    filter << "account_id = #{Current.account.id} "

    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ],
      filter: filter.join(" AND ")
    }

    @pagy, @items = pagy(License::Provider.search(@query, search_options), limit: 10)
    # logger.debug @query
    # logger.debug search_options
    # logger.debug "Pagy: #{@pagy.inspect}"
    # logger.debug @items.count
  end

  def datum
    Current.account.providers
  end

  def datum_name
    "provider"
  end
  
  def back_path
    member_license_providers_path()
  end

  private
  
    def set_item
      @item = Current.providers.find_by(id: params[:id])
    end

    def item_params
      return {} unless params[:license_provider].present?
      params.expect(license_provider: [ :name, :uuid ])
    end  
end