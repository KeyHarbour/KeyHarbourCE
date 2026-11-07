class PermissionService
  def initialize
    @permissions = {}
    @filename = Rails.root.join("config", "permissions.yml")
    load_permissions
  end

  def load_permissions
    if File.exist?(@filename)
      file_content = File.read(@filename)
      @license = YAML.safe_load(file_content)
    else
      # File.write(@filename, {}.to_yaml)
    end
  end

  def save_permissions
    # File.write(@filename, @permissions.to_yaml)
  end

  def get(controller, action, roles)
    @permissions[controller] ||= {}
    @permissions[controller][action] ||= []
    save_permissions
    roles.each { |role| return true if @permissions[controller][action].include?(role) }

    false
  end
end