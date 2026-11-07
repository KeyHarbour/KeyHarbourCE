class Permissions::Admin::Coupons < Permissions::Member::Base
  %w[index edit update show destroy activate desactivate].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      KeyHarbour.saas? && user.admin?
    end
  end   
end
