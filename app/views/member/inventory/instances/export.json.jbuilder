json.array! @instances do |instance|
  json.extract! instance, :name, :uuid, :status
  json.environment instance.environment.name if instance.environment
  json.workspace instance.workspace.name if instance.workspace
  json.category instance.model_category.name if instance.model_category
  
  json.attrs instance.instance_attrs.joins(:model_category_attr).where(inventory_model_category_attrs: { active: true }) do |instance_attr|
    json.extract! instance_attr, :name, :value
  end
end