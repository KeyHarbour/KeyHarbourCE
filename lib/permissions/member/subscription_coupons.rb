class Permissions::Member::SubscriptionCoupons < Permissions::Member::Base
  %w[show edit update new destroy create].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      KeyHarbour.saas? && user.organization_view(organization)
    end
  end   
end
