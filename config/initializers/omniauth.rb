Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.configuration.register.feature("oauth.google")
    puts "google auth enabled".yellow
    google_id = ENV["GOOGLE_ID"]
    google_secret = ENV["GOOGLE_SECRET"]
    if google_id.present? && google_secret.present?
      provider :google_oauth2, 
            google_id, 
            google_secret,
            { scope: 'userinfo.email, userinfo.profile', prompt: 'select_account' }
    else
      Rails.logger.warn "Google OAuth activé mais GOOGLE_ID ou GOOGLE_SECRET manquants."
    end
  end
  if Rails.configuration.register.feature("oauth.github")  
    provider :github, ENV['OAUTH_GITHUB_CLIENT_ID'], ENV['OAUTH_GITHUB_CLIENT_SECRET'], scope: 'user:email'
  end
  if Rails.configuration.register.feature("oauth.microsoft")
    provider :microsoft_graph, 
            ENV["MICROSOFT_ID"], 
            ENV["MICROSOFT_SECRET"],
            { 
              scope: 'openid profile email user.read', 
              prompt: 'select_account',
              base_azure_url: 'https://microsoftonline.com'
            }
  end
end