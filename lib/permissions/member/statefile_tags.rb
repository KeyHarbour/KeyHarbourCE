class Permissions::Member::StatefileTags < Permissions::Member::Base
  %w[create new destroy].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      return true if user.project_edit(project)
      user.workspace_edit(workspace)
    end
  end
end
