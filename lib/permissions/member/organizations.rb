class Permissions::Member::Organizations < Permissions::Member::Base
  %w[edit update].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      KeyHarbour.multi_org? && user.account_admin?
    end
  end 

  %w[new create destroy].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      KeyHarbour.multi_org? && user.organization_permissions(organization) == :admin
    end
  end     

  %w[index].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      KeyHarbour.multi_org?
    end
  end 

  %w[show].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      true
    end
  end  
end
