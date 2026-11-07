require Rails.root.join("lib/registration/register.rb")

Rails.application.configure do
  config.register = Registration::Register.new
end