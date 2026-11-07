class Permissions::Member::Subscriptions < Permissions::Member::Base
  %w[index show create].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      KeyHarbour.saas? && user.account_admin?
    end
  end     
end
