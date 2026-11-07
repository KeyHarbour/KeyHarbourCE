class Permissions::Admin::Users < Permissions::Member::Base
  %w[index edit update show destroy].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      user.admin?
    end
  end     
end
