class Admin::AccountsController < Admin::AdminController
  def index
    @item = datum.new(item_params)

    query = params[:account]&.[](:name).presence || "*"
    logger.debug "Search query: #{query}".green

    filter = []


    logger.debug filter
    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ],
      filter: filter.join(" AND ")
    }
    @pagy, @items = pagy(datum.search(query, search_options), limit: 10)
  end

  def datum
    Account.unscoped.all.order(created_at: :asc)
  end

  def datum_name
    t('activerecord.models.account')
  end
  
  def back_path
    # return admin_account_path(@item) if @item && !@item.new_record? && action_name.to_sym != :index
    admin_accounts_path
  end

  def activate
    @item.update(status: 'active')
    redirect_back(fallback_location: root_path) 
  end

  def unactivate
    @item.update(status: 'disabled')
    redirect_back(fallback_location: root_path) 
  end

  def unarchived
    activate
  end

  private
  def set_breadcrumbs
    @breadcrumbs ||= []
  end

  def set_items
    @item = datum.find_by(id: params[:id]) if params[:id]
  end

  def item_params
    unless params[:account].present?
      return {}
    end
    params.expect(account: [ :name, :address1, :address2, :zip, :country_code, :province_code, :billing_contact ])
  end
end