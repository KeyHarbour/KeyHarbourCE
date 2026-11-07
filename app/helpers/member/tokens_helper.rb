module Member::TokensHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/tokens", member_organization_tokens_path(@organization), @item&.name, @item&.id )
    result
  end

  def new_item_url
    new_member_project_token_path(@project)
  end

  def form_url
    if @item.new_record?
      return member_project_tokens_path(@project) if @project.present?
      member_organization_tokens_path(@organization)
    else
      member_token_path(@item)
    end
  end

  def search
    true
  end

  def add_button(position)
    controller_items[:'member/org_tokens'].merge(path: new_item_url, title:  new_name(@item)) if position == :top and action_name == 'index'
  end

  def token_scope(token)
    return "Project" if token.scopable_type == "Project"
    return "Organization" if token.scopable_type == "Organization"
    return "Workspace" if token.scopable_type == "Workspace"
    'Application'
  end

  def token_scopable(token)
    return "#{token.scopable.name}" if token.scopable_type == "Organization"
    return "#{token.scopable.organization.name} / #{token.scopable.name}" if token.scopable_type == "Project"
    return "#{token.scopable.project.organization.name} / #{token.scopable.project.name} / #{token.scopable.name}" if token.scopable_type == "Workspace"
    "#{token.scopable.name}"
  end

  def scope_color(token)
    return "bg-orange" if token.workspace_token?
    return "bg-lime" if token.project_token?
    return "bg-green" if token.organization_token?
    ""
  end

  def status_color(token)
    return "bg-red" if token.expiration.past?
    return "bg-yellow" if token.expiration.advance(days: -7).past?
    "bg-green"
  end
end
