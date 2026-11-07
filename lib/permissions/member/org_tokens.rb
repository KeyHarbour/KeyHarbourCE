class Permissions::Member::OrgTokens < Permissions::Member::Base
  %w[index show edit update new destroy create].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      return true if user.organization_edit(organization)

      return true if user.project_edit(project)

      user.workspace_list(project)
    end
  end
end
