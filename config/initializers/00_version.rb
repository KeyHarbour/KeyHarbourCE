Rails.application.configure do
  config.version = File.read("VERSION")
  puts "running version: #{config.version}"
end