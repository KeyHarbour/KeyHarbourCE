class Member::TeamsController < Member::MemberController
  before_action :validate_admin?
  def index
    @item = datum.build(item_params)
    @query = @item.name || '*'

    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ]
    }

    @pagy, @items = pagy(datum.search(@query, search_options), limit: 10)
  end

  def datum
    Current.teams
  end

  def datum_name
    "team"
  end
  
  def back_path
    member_teams_path
  end

  private
    def set_items
    end

    def item_params
      return {} unless params[:team].present?
      # params.permit(:user_id, :role_name, project_ids: [], workspace_ids: [], account_ids: [])

      params.expect(team: [ 
        :name, 
        :description, 
        :source, 
        project_editor_ids: [], workspace_editor_ids: [], organization_editor_ids: [],
        project_viewer_ids: [], workspace_viewer_ids: [], organization_viewer_ids: [],
        project_admin_ids: [], workspace_admin_ids: [], organization_admin_ids: []
      ])
    end

    def set_item
      @item = Team.find_by!(uuid: params[:id])
    end
end
