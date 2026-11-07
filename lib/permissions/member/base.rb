class Permissions::Member::Base
  attr_reader :user, :action, :organization, :project, :workspace

  def initialize(user, action, organization, project = nil, workspace = nil)
    @user = user
    @action = action
    @organization = organization
    @project = project
    @workspace = workspace    
  end
end
