class Permissions::Admin::Organizations < Permissions::Member::Base
  %w[index edit update show destroy activate].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      KeyHarbour.multi_org? && user.admin?
    end
  end     
end
