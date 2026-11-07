module Member::Wizard::Statefiles::StatefilesHelper
  def breadcrumbs
    [ 
      controller_items[:"member/dashboard"].merge(path: member_root_path, only_icon: true), 
      controller_items[:"member/wizard/statefiles/statefiles"]
    ]
  end

  def path_create_organization
    member_wizard_statefiles_create_organization_path
  end

  def path_create_project
    member_wizard_statefiles_create_project_path
  end

  def path_create_workspace
    member_wizard_statefiles_create_workspace_path
  end
end