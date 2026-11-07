module Member::WorkspacesHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/workspaces", member_project_workspaces_path(@project), @workspace&.name, @workspace&.uuid )
    result
  end

  def add_button(position)
    controller_items[:'member/workspaces'].merge(path: new_item_url, title: new_name(@item)) if position == :top and action_name == 'index'
  end

  def new_item_url
    new_member_project_workspace_path(@project)
  end

  def form_url
    return member_project_workspaces_path(@project) if @item.new_record?
    member_workspace_path(@item)
  end
end
