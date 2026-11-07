class Permissions::Member::Accounts < Permissions::Member::Base
  %w[show index].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      true
    end
  end    

  %w[new create].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      true
    end
  end   
end
