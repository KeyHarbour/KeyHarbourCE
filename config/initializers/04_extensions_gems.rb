require 'key_harbour_core'

Rails.application.config.to_prepare do
  if defined?(ActiveRecord::Base) && defined?(ApplicationRecord)
    organization_klass = "Organization".safe_constantize
    if organization_klass
      organization_klass.include(ExtensionOrganization)
    else
      puts "⚠️ Impossible d'étendre KeyHarbourCore::Organization : la constante reste introuvable."
    end

    account_klass = "Account".safe_constantize
    if account_klass
      account_klass.include(ExtensionAccount)
    else
      puts "⚠️ Impossible d'étendre KeyHarbourCore::Account : la constante reste introuvable."
    end

  end
end
