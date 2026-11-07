log_path = Rails.root.join("log", "credit_#{Rails.env}.log")
CreditLogger = Logger.new(log_path, 3, 10.megabytes)

CreditLogger.formatter = proc do |severity, datetime, _progname, msg|
  "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity} -- : #{msg}\n"
end