class Permissions::Member::Events < Permissions::Member::Base
  %w[show index].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      user.organization_view(organization)
    end
  end    

  %w[new create destroy edit update].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      user.organization_edit(organization)
    end
  end   
end
