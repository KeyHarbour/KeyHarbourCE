FerrumPdf.configure do |config|
  # Si nous sommes sous Linux (ex: Docker / Production)
  if RUBY_PLATFORM.include?("linux")
    config.browser_options = {
      "no-sandbox": nil,
      "disable-setuid-sandbox": nil,
      "disable-dev-shm-usage": nil
    }
    
    # Indique à Ferrum le chemin exact du binaire Chromium sous Linux
    config.browser_path = "/usr/bin/chromium"
  end
end
