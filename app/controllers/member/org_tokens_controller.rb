class Member::OrgTokensController < Member::OrganizationsController
  def create
    @item = @organization.token_organizations.new(item_params)
    if @item.save
      @pagy, @items = pagy(datum.all)
      render turbo_stream: turbo_stream.update("form_to_replace", partial: "create", locals: { item: @item, items: @items, pagy: @pagy })
    else
      render :new, status: :unprocessable_entity
    end
  end

  def datum
    @organization.token_organizations
  end

  def new
    @item = datum.new(scopable: @organization)
  end
  #
  def show
    set_item
    # redirect_to back_path
  end

  def index
    @item = datum.build(item_params)
    @query = @item.name || '*'

    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ]
    }

    @pagy, @items = pagy(datum.search(@query, search_options), limit: 10)
  end

  def datum_name
    "token"
  end
  
  def back_path
    member_organization_org_tokens_path(@organization)
  end

  def destroy
    @item = @organization.token_organizations.find(params[:id])
    @organization = @item.scopable
    @item.destroy!
    redirect_to back_path, status: :see_other, notice: "#{datum_name.capitalize} was successfully destroyed."
  end

  private
    def set_item
      @item = TokenOrganization.find(params[:id])
      @organization = @item.scopable
    end

    def set_items
      @organization = Current.organizations.find_by(uuid: params[:organization_id])
    end

    def item_params
      return {} unless params[:token_organization].present?

      params.expect(token_organization: [ :name, :expiration, :scopable_type, :environment_id ])
    end
end