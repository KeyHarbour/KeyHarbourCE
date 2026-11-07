module Member::ProjectTokensHelper
  def new_item_url
    new_member_project_project_token_path(@project)
  end

  def form_url
    return member_project_project_tokens_path(@project) if @item.new_record?
    member_project_token_path(@item) if @project.present?
  end
end
