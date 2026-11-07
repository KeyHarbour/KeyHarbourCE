class Member::Inventory::InventoryController < Member::OrganizationsController
  private
    # def set_breadcrumbs
    #   super()
    #   @breadcrumbs << { name: t('activerecord.models.model_category').pluralize, path: member_organization_inventory_model_categories_path(@organization) } if controller_name == "model_categories" || !@model_category.nil?
    #   logger.debug "Breadcrumbs - Model Category: #{@model_category.inspect}".green
    #   @breadcrumbs << { name: @model_category.name, path: member_inventory_model_category_path(@model_category) } unless @model_category.nil?
    #
    #   @breadcrumbs << { name: t('activerecord.models.model_family').pluralize, path: member_organization_inventory_model_families_path(@organization) } if controller_name == "model_families" || !@model_family.nil?
    #   @breadcrumbs << { name: @model_family.name, path: member_model_family_path(@model_family) } unless @model_family.nil?
    #
    #   @breadcrumbs << { name: t('activerecord.models.instance').pluralize, path: member_organization_inventory_instances_path(@organization) } if controller_name == "instances" || !@instance.nil?
    #   @breadcrumbs << { name: @instance.name, path: member_instance_path(@instance) } unless @instance.nil?
    # end

    def set_organization
      return if @organization.present?
      @organization = Current.organizations.find_by(uuid: params[:organization_id])
    end
  
    def set_item
      @item = datum.find_by(name: params[:id])
    end
end