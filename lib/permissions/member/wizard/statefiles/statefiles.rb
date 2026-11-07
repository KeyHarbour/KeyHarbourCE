class Permissions::Member::Wizard::Statefiles::Statefiles < Permissions::Member::Base
  %w[new_organization create_organization create_project create_workspace].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      return true if user.project_view(project)
      user.workspace_edit(workspace)
    end
  end   
end
