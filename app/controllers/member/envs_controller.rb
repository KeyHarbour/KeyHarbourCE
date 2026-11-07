class Member::EnvsController < Member::WorkspacesController
  def show
    @pagy, @items = pagy(@workspace.statefiles.where(environment: @item))
  end

  def datum
    @organization.environments
  end

  def datum_name
    "environment"
  end
  
  def back_path
    member_organization_environments_path(@organization)
  end

  private
    def item_params
      params.expect(environment: [ :name, :active ])
    end

    def set_item
      @item = datum.find_by!(name: params[:id])
    end
end
