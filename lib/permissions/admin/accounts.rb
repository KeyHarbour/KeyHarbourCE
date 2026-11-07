class Permissions::Admin::Accounts < Permissions::Member::Base
  %w[index activate unactivate unarchived destroy edit update].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      user.admin?
    end
  end   
end
