module Member::StatefilesHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/statefiles", member_workspace_statefiles_path(@workspace, environment: @environment.name), @item&.uuid, @workspace.id )
    result
  end

  def new_item_url
    new_member_workspace_statefile_path(@workspace)
  end

  def form_url
    return member_workspace_statefiles_path(@workspace) if @item.new_record?
    member_statefile_path(@item)
  end

  def index_page_name
    t('member.statefiles.index.title')
  end

  def add_button(position)
    nil
  end

  def page_title
    return super unless action_name == 'show'


    item = breadcrumbs.last
    capture do
      concat icon(item[:icon]) if item[:icon].present?
      concat ' '
      prefix = ''
      prefix = new_name(@item) if action_name == 'new'
      prefix = "Edit " + t("activerecord.models.#{@item.class.name.underscore}") if action_name == 'edit'
      full_title = [ prefix, item[:page_title] || item[:title] ].compact.join(' ')
      concat full_title + " / " + @item.uuid
    end
  end

  def search
    false
  end

  def step_back
    return false unless action_name == 'show'
    member_workspace_statefiles_path(@workspace, environment: @environment.name)
  end
end
