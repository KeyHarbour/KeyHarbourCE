class Permissions::Member::License::Quotes < Permissions::Member::Base
   %w[index].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      KeyHarbour.license? && user.organization_view(@organization)
    end
  end 

   %w[show edit update new create destroy compare].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      KeyHarbour.license? && user.organization_edit(@organization)
    end
  end     
end
