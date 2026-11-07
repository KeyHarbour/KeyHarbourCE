require Rails.root.join("app/services/permission_service.rb")

Rails.application.configure do
  config.permission_service = PermissionService.new
end