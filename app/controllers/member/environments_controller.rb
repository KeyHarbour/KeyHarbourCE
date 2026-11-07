class Member::EnvironmentsController < Member::OrganizationsController
  def index
    @item = datum.build(item_params)
    @query = @item.name || '*'
    logger.debug "Query: #{@query}"
    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ]
    }

    @pagy, @items = pagy(datum.search(@query, search_options), limit: 10)
  end

  def datum
    @organization.environments
  end

  def datum_name
    "environment"
  end
  
  def back_path
    member_organization_environments_path(@organization)
  end

  private
  
    def set_item
      @item = Environment.find_by(id: params[:id])
    end

    def item_params
      return {} unless params[:environment].present?
      params.expect(environment: [ :name, :active ])
    end
end
