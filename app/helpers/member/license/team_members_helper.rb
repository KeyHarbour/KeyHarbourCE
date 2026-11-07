module Member::License::TeamMembersHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/license/team_members", member_license_team_members_path, "", @item.id )
    result
  end

  def add_button(position)
    controller_items[:'member/license/team_members'].merge(path: new_item_url, title:  new_name(@item)) if position == :top and action_name == 'index'
  end

  def search
    false
  end

  def index_page_name
    "Hierarchical"
  end

  def new_item_url
    new_member_license_team_member_path
  end

  def form_url    
    return member_license_team_members_path(locale: I18n.locale) if @item.new_record?
    member_license_team_member_path(@item, locale: I18n.locale)
  end
end
