class Admin::OrganizationsController < Admin::AdminController
  def datum
    Organization.all
  end

  def datum_name
    "organization"
  end
  
  def back_path
    admin_accounts_path
  end

  private
  def set_parent_obj
    @account = Account.find(params[:account_id]) if params[:account_id]
  end

  def item_params
    params.expect(organization: [ :name, :status, :description ])
  end

  def set_breadcrumbs
    @breadcrumbs ||= []
    @breadcrumbs << { name: "Organizations", path: admin_organizations_path }
    set_breadcrumb_actions
  end

  def set_breadcrumb_actions
    super()
    @breadcrumbs << { name: @item.name } if action_name.to_sym == :show
  end 
  
  def set_item
    @item = datum.find_by!(uuid: params[:id])
  end
end
