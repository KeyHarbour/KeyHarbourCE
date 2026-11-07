class Permissions::MissionControl::Jobs::Queues < Permissions::Member::Base
  %w[index destroy edit update show].each do |method_name|
    define_method("#{method_name}?".to_sym) do
      user.admin?
    end
  end  
end
