class Member::OrganizationsController < Member::MemberController
  def index
    @item = datum.build(item_params)
    @query = @item.name || '*'

    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ]
    }

    @pagy, @items = pagy(datum.search(@query, search_options), limit: 10)
  end
  
  def create
    if controller_name == 'organizations'
      @item = datum.new(item_params)

      if @item.save
        redirect_to member_organization_path(@item), notice: "#{datum_name.capitalize} was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    else
      super()
    end
  end

  def datum
    Current.organizations.not_archived.current_user(Current)
  end

  def datum_name
    t('activerecord.models.organization')
  end
  
  def back_path
    return member_organization_path(@item) if @item && !@item.new_record? && action_name.to_sym != :index
    member_organizations_path
  end

  private
    def set_items
      @days_range = Current.billing_range
      return if controller_name == 'organizations'

      if params[:organization_id]
        @organization = Current.organizations.find_by(uuid: params[:organization_id])
      else
        set_item
        @organization = @item.organization
      end
    end

    def item_params
      return {} unless params[:organization].present?
      params.expect(organization: [ :name, :description ])
    end

    def set_item
      if controller_name == 'organizations'
        @item = datum.find_by!(uuid: params[:id])
        @organization = @item
      else
        super()
      end
    end
end