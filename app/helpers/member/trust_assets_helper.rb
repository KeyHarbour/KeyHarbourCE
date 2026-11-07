module Member::TrustAssetsHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/trust_assets", member_workspace_trust_assets_path(@workspace, environment: @environment.name), @item&.name, @workspace.id )
    result
  end

  def add_button(position)
    controller_items[:'member/trust_assets'].merge(path: new_item_url, title: new_name(@item)) if position == :top and action_name == 'index'
  end

  def new_item_url
    new_member_workspace_trust_asset_path(@workspace, environment: @environment.name)
  end

  def form_url
    return member_workspace_trust_assets_path(@workspace) if @item.new_record?
    member_trust_asset_path(@item)
  end

  def index_page_name
    t('member.trust_assets.index.title')
  end
end
