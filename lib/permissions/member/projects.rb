class Permissions::Member::Projects < Permissions::Member::Base
   %w[index].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      organization.projects.each do |prj|
        return true if user.project_edit(prj)
      end
      user.organization_edit(organization)
    end
  end   

   %w[show].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      user.project_view(project)
    end
  end     

   %w[edit update].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      user.project_edit(project)
    end
  end  

  %w[new create destroy].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      user.organization_edit(organization)
    end
  end 
end
