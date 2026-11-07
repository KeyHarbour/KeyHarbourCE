module Member::ProjectsHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/projects", member_organization_projects_path(@organization), @project&.name, @project&.uuid )
    result
  end

  def add_button(position)
    controller_items[:'member/projects'].merge(path: new_item_url, title:  new_name(@item)) if position == :top and action_name == 'index'
  end

  def new_item_url
    new_member_organization_project_path(@organization)
  end

  def form_url
    return member_organization_projects_path(@organization, locale: I18n.locale) if @item.new_record?
    member_project_path(@item, locale: I18n.locale)
  end

  def search
    true
  end
end
