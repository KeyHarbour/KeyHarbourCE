require "openssl"
require 'yaml'
require "net/http"
require "json"

module Registration
  class Register
    attr_accessor :license_id
    def initialize
      @features = []

      is_server = defined?(Rails::Server) || 
                  (defined?(Puma) && !!$PROGRAM_NAME.match(/puma/)) || 
                  (defined?(Passenger) && !!$PROGRAM_NAME.match(/passenger/))

      return unless is_server
      puts "Registering app... ".green unless Rails.env.test?
      @config = Rails.application.config_for("ikigailab")
      @timestamp = Time.now.to_i.to_s
      if Rails.env.test? || ENV["SKIP_REGISTRATION"]
        puts "  Test mode, skipping Registration".yellow unless Rails.env.test?
      elsif read_license.dig("shared", "registration", "disconnected") == true
        puts "  Disconnected mode, skipping registration".yellow unless Rails.env.test?
        write_license(read_license)
      elsif ENV['HOST'] == 'localhost'
        puts "  localhost use as server, skipping registration... working with minimum feature".red
        save_license
      else
        save_license
      end
      puts @identity["production"]["uuid"] unless Rails.env.test?
      puts "Registration done.".green unless Rails.env.test?
    end

    def features
      @features
    end

    def feature(item)
      # Rails.logger.debug "All features: #{@features}"
      item = item.to_s
      return false if @features.empty?

      return true if @features.include?(item) && @features[item] == true

      false
    end

    def license_file_name
      file_name = Rails.root.join("storage", "license.enc")
      FileUtils.mkdir_p(file_name.dirname) 
      file_name 
    end

    def read_license
      return @license if @license

      path = Rails.root.join("storage", "license.yml")
      # file_content = File.read(path)
      # @license = YAML.safe_load(file_content)
      # return @license
      
      File.delete(path) if File.exist?(path)
      begin
        file_content = File.read(license_file_name)
        message = Rails.application.message_verifier(identity["production"]["uuid"]).verify(file_content)
        @license = YAML.safe_load(message)
        @license["shared"]["features"].each do |key, value|
          puts "  Feature #{key} activated".light_green unless Rails.env.test?
        end
      rescue Errno::ENOENT
        @license = {}
      rescue Psych::SyntaxError
        puts "Le format YAML est invalide.".red
        @license = {}
      end
      @license
    end

    def write_license(content)
      message = Rails.application.message_verifier(identity["production"]["uuid"]).generate(content.to_yaml)
      File.write(license_file_name, message)
      # File.write(Rails.root.join("storage", "license.yml"), content.to_yaml)
    end

    def save_license
      @license_id, features = process
      return nil if @license_id.nil?

      license = read_license

      license["shared"] ||= {}
      license["shared"]["registration"] ||= {}
      license["shared"]["registration"]["license_key"] = license_id

      license["shared"]["features"] = {}
      features.each { |feature_name| license["shared"]["features"][feature_name] = true  }
      @features = license["shared"]["features"]
      write_license(license)
    end

    def identity
      return @identity if @identity

      file_name = Rails.root.join("storage", "identity.yml")
      FileUtils.mkdir_p(file_name.dirname)

      @identity = if File.exist?(file_name)
        YAML.load_file(file_name) || {}
      else
        {}
      end

      @identity["production"] ||= {}
      @identity["production"]["uuid"] ||= SecureRandom.uuid
      @identity["production"]["host"] = ENV['HOST']

      File.write(file_name, identity.to_yaml)
      @identity
    end

    def system_machine_id
      case RbConfig::CONFIG['host_os']
      when /darwin/ # macOS
        # Méthode 1 : ioreg nettoyé (récupère directement le dernier élément sans dépendre de la colonne)
        uuid = `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | awk '{print $NF}'`.tr('"', '').strip rescue nil
        
        # Méthode 2 de secours : system_profiler si ioreg a échoué
        if uuid.blank? || uuid.include?("=")
          uuid = `system_profiler SPHardwareDataType | grep -i "UUID" | awk '{print $NF}'`.strip rescue nil
        end
        
        uuid.presence
      when /linux/
        File.read('/etc/machine-id').strip rescue File.read('/var/lib/dbus/machine-id').strip rescue nil
      when /mswin|mingw|cygwin/ # Windows
        `wmic csproduct get uuid`.split("\n")[1]&.strip rescue nil
      else
        nil
      end
    end


    def safe_count(model)
      model_class = model.constantize rescue nil
      unless model_class.nil?
        model.camelize.constantize.all.count
      else
        nil
      end
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
      nil
    end

    def payload
      { 
        instance: {
          url: identity["production"]["host"], 
          uuid: identity["production"]["uuid"],
          version: Rails.configuration.version.gsub("\n", ""),
          machine_id: system_machine_id,
          accounts: safe_count("Account"),
          key_value_stores: safe_count("KeyValueStore"),
          statefiles: safe_count("Statefile"),
          tokens: safe_count("Token"),
          trust_assets: safe_count("TrustAsset"),
          applications: safe_count("License::Application"),
          organizations: safe_count("Organization"),
          users: safe_count("User"),
          projects: safe_count("Project"),
          workspaces: safe_count("Workspace")
        }
      }.to_json
    end

    def signature
      data = "#{@timestamp}.#{payload}"
      OpenSSL::HMAC.hexdigest("SHA256", @config.secret_key, data)
    end

    def process
      return [ nil, nil ] if @config.serveur_url.nil?

      @timestamp = Time.now.to_i.to_s
      uri = URI(@config.serveur_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = @config.verify_mode.constantize
      Rails.logger.debug "Ready to query" unless Rails.env.test?

      puts "  Query to ikigai to validate license".light_blue unless Rails.env.test?
      http.open_timeout = 5
      http.read_timeout = 10
      http.write_timeout = 5
      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/json"
      request["X-Signature"] = signature
      request["X-Timestamp"] = @timestamp
      request.body = payload

      begin
        response = http.request(request)
        data = JSON.parse(response.body)
        Rails.logger.debug "Response: #{data}"
        Rails.logger.debug "Response: #{data["license_id"]}"
        [ data["licence_id"], data["features"] ]
      rescue Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout => e
        # Gérer le dépassement de délai ici (ex: logger l'erreur ou réessayer)
        puts "Erreur de timeout : #{e.message}"
      end
    end
  end
end