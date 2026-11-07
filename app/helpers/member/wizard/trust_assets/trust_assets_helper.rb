module Member::Wizard::TrustAssets::TrustAssetsHelper
  def breadcrumbs
    [ 
      controller_items[:"member/dashboard"].merge(path: member_root_path, only_icon: true), 
      controller_items[:"member/wizard/trust_assets/trust_assets"]
    ]
  end

  def path_create_organization
    member_wizard_trust_assets_create_organization_path
  end

  def path_create_project
    member_wizard_trust_assets_create_project_path
  end

  def path_create_workspace
    member_wizard_trust_assets_create_workspace_path
  end
end