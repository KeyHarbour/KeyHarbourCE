module Member::TeamsHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/teams", member_teams_path, @item&.name, @item&.id )
    result
  end

  def add_button(position)
    controller_items[:'member/teams'].merge(path: new_item_url, title:  new_name(@item)) if position == :top and action_name == 'index'
  end

  def display_back
    true
  end
  def new_item_url
    new_member_team_path()
  end

  def form_url
    return member_teams_path(locale: I18n.locale) if @item.new_record?
    member_team_path(@item, locale: I18n.locale)
  end
end
