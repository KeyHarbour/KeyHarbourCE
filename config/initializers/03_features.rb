module KeyHarbour
  def self.allow_public?
    return true if User.all.count == 0
    return true if User.count == 1

    Rails.configuration.register.feature(:allow_public) == true
  end

  def self.oauth_google?
    Rails.configuration.register.feature("oauth.google") == true
  end

  def self.oauth_microsoft?
    Rails.configuration.register.feature("oauth.microsoft") == true
  end

  def self.oauth_github?
    Rails.configuration.register.feature("oauth.github") == true
  end

  def self.key_value?
    return true
    Rails.configuration.register.feature(:key_value) == true
  end

  def self.multi_account?
    return true if User.all.count == 0
    return true if User.count == 1

    Rails.configuration.register.feature(:multi_account) == true
  end

  def self.multi_org?
    Rails.configuration.register.feature(:multi_org) == true
  end

  def self.multi_team?
    Rails.configuration.register.feature(:multi_team) == true
  end

  def self.saas?
    Rails.configuration.register.feature(:saas) == true
  end

  def self.tf_statefile?
    return true
    Rails.configuration.register.feature(:tf_statefile) == true
  end

  def self.trust_assets?
    return true
    Rails.configuration.register.feature(:trust_assets) == true
  end

  def self.license?
    Rails.configuration.register.feature(:license) == true
  end
end
