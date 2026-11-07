module Member::KeyValueStoresHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/key_value_stores", member_workspace_key_value_stores_path(@workspace, environment: @environment.name), @item&.key, @workspace.id )
    result
  end

  def add_button(position)
    controller_items[:'member/key_value_stores'].merge(path: new_item_url, title: new_name(@item)) if position == :top and action_name == 'index'
  end

  def new_item_url
    new_member_workspace_key_value_store_path(@workspace, environment: @environment.name)
  end

  def form_url
    return member_workspace_key_value_stores_path(@workspace) if @item.new_record?
    member_key_value_store_path(@item)
  end

  def index_page_name
    t('member.key_value_stores.index.title')
  end
end
