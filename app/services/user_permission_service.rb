class UserPermissionService
  attr_reader :user, :controller, :action, :organization, :project, :workspace

  def initialize(user, controller, action, organization = nil, project = nil, workspace = nil)
    @user = user
    @controller = controller
    @action = action
    @organization = organization
    @project = project
    @workspace = workspace
  end

  def allowed?
    class_name = "Permissions::#{controller.camelize}"
    permission_class = class_name.safe_constantize

    if permission_class.nil?
      generate_missing_permission_file(class_name)
      SecurityLogger.warn("⚠️ Fichier de permission manquant créé automatiquement. Veuillez recharger la page. (Classe: #{class_name})".red)

      return false 
    end
    permission_instance = permission_class.new(user, action, organization, project, workspace)

    action_method = "#{action}?"
    unless permission_instance.respond_to?(action_method)
      SecurityLogger.warn("⚠️ Pas de permission defini pour cette méthode (Classe: #{class_name} / #{action_method})".red)
      return false
    end
    permission = permission_instance.send(action_method)
    log_security_event(permission)
    permission
  end

  private

  def member_dashboard_index
    true
  end

  def member_organizations_index
  end

  def log_security_event(allowed)
    user_info = @user ? "User ID: #{user.email_address}" : "Anonymous"
    message = "[#{allowed ? "ACCESS" : "DENIED"}] #{user_info} tried to access #{controller}##{action} with organization: #{organization} / #{ project} / #{ workspace }"
    
    if allowed
      SecurityLogger.info(message.green) # Écrit en INFO pour les accès valides (optionnel)
    else
      SecurityLogger.warn(message.red) # Écrit en WARN pour les refus
    end
  end

  def generate_missing_permission_file(class_name)
    return unless Rails.env.development?
    
    relative_path = class_name.underscore
    file_path = Rails.root.join('lib', "#{relative_path}.rb")
    FileUtils.mkdir_p(File.dirname(file_path))
    
    template_content = <<~RUBY
      class #{class_name} < Permissions::Member::Base
      end
    RUBY

    File.write(file_path, template_content)
  end
end