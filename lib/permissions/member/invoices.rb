class Permissions::Member::Invoices < Permissions::Member::Base
  %w[show edit update new destroy create].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      user.organization_view(organization)
    end
  end  
end
