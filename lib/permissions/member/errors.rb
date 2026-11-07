class Permissions::Member::Errors < Permissions::Member::Base
  %w[e403_member].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      true
    end
  end    
end
