class Permissions::Member::Workspaces < Permissions::Member::Base
  %w[index].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      return true if user.project_view(project)
      user.workspace_list(project)
    end
  end
  
  %w[show edit update].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      return true if user.project_view(project)
      user.workspace_edit(workspace)
    end
  end 
  
  %w[new destroy create].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      user.project_edit(project)
    end
  end  
end
