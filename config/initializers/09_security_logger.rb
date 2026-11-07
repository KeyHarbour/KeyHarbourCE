log_path = Rails.root.join("log", "security_#{Rails.env}.log")

SecurityLogger = Logger.new(log_path, 3, 10.megabytes)

SecurityLogger.formatter = proc do |severity, datetime, _progname, msg|
  "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity} -- : #{msg}\n"
end