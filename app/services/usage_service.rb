class UsageService
  BILLABLE_QUERIES = %w[KeyValueStore Statefile]
  def initialize
    puts "Calculating usage... ".green unless Rails.env.test?
    # calculate_queries
    puts "Registering usage... ".green unless Rails.env.test?
    @config = Rails.application.config_for("ikigailab")
    @timestamp = Time.now.to_i.to_s
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

  def payload(account)
    process_date = Time.current.advance(days: -1)
    # usage_daily_accounts = account.usage_daily_accounts.where(day: process_date).first_or_initialize
    employees = account.usage_daily_accounts.where(day: process_date.all_day, service_name: 'License').sum(:units)
    queries = account.usage_daily_accounts.where(day: process_date.all_day, service_name: Cost.query_service_names).sum(:credits)
    { 
      instance: {
        uuid: identity["production"]["uuid"]
      },
      instance_usage: {
        date: process_date.to_date,
        queries: queries,
        employees: employees
      },
      account: {
        id: account.id,
        name: account.name,
        country_code: account.country_code,
        province_code: account.province_code,
        billing_contact: account.billing_contact
      }
    }.to_json
  end

  def signature(payload)
    data = "#{@timestamp}.#{payload}"
    OpenSSL::HMAC.hexdigest("SHA256", @config.secret_key, data)
  end

  # def add_credit(account, data)
  #   return nil unless data.include?("credits")
  #   return nil unless data["credits"]["queries"].to_i > 0 || data["credits"]["employees"].to_i > (account.account_histories.where(is_credit: true).last&.employees || 0)
  #   return nil unless account.account_histories.where(is_credit: true, uuid: data["credits"]["uuid"]).count == 0
  #   account.account_histories.create!(day: data["credits"]["date"], employees: data["credits"]["employees"], queries: data["credits"]["queries"], uuid: data["credits"]["uuid"], is_credit: true)
  # end

  def process
    return [ nil, nil ] if @config.serveur_url.nil?

    uri = URI(@config.serveur_url)
    puts @config.serveur_url  unless Rails.env.test?
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = @config.verify_mode.constantize
    Rails.logger.debug "Ready to query"

    puts "  Query to ikigai to consolidate usages".light_blue  unless Rails.env.test?

    request = Net::HTTP::Patch.new(uri.path)
    request["Content-Type"] = "application/json"
    request["X-Timestamp"] = @timestamp
    Account.all.each do |account|
      request.body = payload(account)
      request["X-Signature"] = signature(request.body)
      Rails.logger.debug "Payload for #{account.name}: #{request.body}".green

      response = http.request(request)
      data = JSON.parse(response.body)
      # add_credit(account, data)
      Rails.logger.debug "Response Data: #{data}"
    end
    nil
  end

  def self.call
    @usage_service = new
    @usage_service.process
  end
end