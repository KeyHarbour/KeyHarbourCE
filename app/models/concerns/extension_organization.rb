module ExtensionOrganization
  extend ActiveSupport::Concern

  included do
    validate :check_license, on: :create
  end

  def check_license
    if Organization.all.count >= 1 && KeyHarbour.multi_org? == false
      errors.add(:base, "License restriction only one org is allowed with the version ! Contact info@keyharbour.ca for more details") 
    end
  end
end