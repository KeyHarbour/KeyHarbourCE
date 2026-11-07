module Member::Inventory::InstancesHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/inventory/instances", member_organization_inventory_instances_path(@organization), @item&.name, @organization.id )
    result
  end

  def add_button(position)
    nil
  end

  def search
    false
  end
end