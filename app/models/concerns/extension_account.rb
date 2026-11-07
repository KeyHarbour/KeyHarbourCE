module ExtensionAccount
  extend ActiveSupport::Concern

  included do
    validate :check_license, on: :create
  end

  def check_license
    if Account.all.count >= 1 && KeyHarbour.multi_account? == false
      errors.add(:base, "License restriction only one org is allowed with the version ! Contact info@keyharbour.ca for more details") 
    end
  end

  def build_default_org_and_sub
    organization = organizations.create(name: I18n.t('member.accounts.create.my_organization'), description: I18n.t('member.accounts.create.my_organization_description'))
    envs = []
    envs << organization.environments.create(name: 'Prod', active: true)
    envs << organization.environments.create(name: 'Test', active: true)
    envs << organization.environments.create(name: 'Dev', active: true)
    project = organization.projects.create(name: I18n.t('member.accounts.create.my_project'), environments: envs, description: I18n.t('.my_project_description'))
    workspaces = []
    workspaces << project.workspaces.create(name: I18n.t('member.accounts.create.my_infra'))
    workspaces << project.workspaces.create(name: I18n.t('member.accounts.create.my_app'))
    workspaces[0].trust_assets.create(environment: envs[0], name: "keyharbour.ca", format: :tls_certificate, consumer: "website" )
    workspaces[0].key_value_stores.create(environment: envs[0], key: I18n.t('member.accounts.create.my_public_key'), value: I18n.t('member.accounts.create.my_public_value'), private: false )
    workspaces[0].key_value_stores.create(environment: envs[0], key: I18n.t('member.accounts.create.my_private_key'), value: I18n.t('member.accounts.create.my_private_value'), private: true )
    workspaces[0].key_value_stores.create(environment: envs[0], key: I18n.t('member.accounts.create.my_private_one_time_only_key'), value: I18n.t('member.accounts.create.my_private_one_time_only_value'), private: true, one_time_only: true )
  end
end