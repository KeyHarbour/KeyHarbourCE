class Permissions::Member::Users < Permissions::Member::Base
  def index?
    user.account_admin?
  end  

  %w[new create show].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      return true if user.project_view(project)
      user.workspace_list(project)
    end
  end    
end
