class Permissions::Member::KeyValueStores < Permissions::Member::Base
  %w[index].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      return true if user.project_view(project)
      user.workspace_list(project)
    end
  end  
  
  %w[show edit update new destroy create].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      return true if user.project_edit(project)
      user.workspace_edit(workspace)
    end
  end  
end
