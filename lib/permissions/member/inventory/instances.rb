class Permissions::Member::Inventory::Instances < Permissions::Member::Base
   %w[index export].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      user.organization_view(@organization)
    end
  end 

   %w[show edit update new create destroy].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      user.organization_edit(@organization)
    end
  end 
end
