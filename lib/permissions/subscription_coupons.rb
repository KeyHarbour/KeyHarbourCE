class Permissions::SubscriptionCoupons < Permissions::Member::Base
  %w[create].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      true
    end
  end 
end
