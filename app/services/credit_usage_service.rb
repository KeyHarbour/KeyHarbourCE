class CreditUsageService
  attr_reader :timestamp, :day, :processed_date

  def initialize(day = nil)
    CreditLogger.info "Start calculating usage".green
    if day
      @day = day
    else
      get_next_date
    end
    CreditLogger.info "Working on day #{day}".light_green
    @timestamp = Time.now.to_i.to_s
  end

  def get_next_date
    if ProcessedDate.all.count == 0
      @day = ApiQuery.order(date: :asc).first&.date || Date.current
    else
      @day = ProcessedDate.order(day: :desc).first.day
    end
    @processed_date = ProcessedDate.create_or_find_by(day: day.advance(days: 1))
    processed_date.update(start_at: DateTime.now)
  end

  def usage_daily_workspaces
    all_queries = ApiQuery.where(date: day.all_day)
    Cost.query_service_names.each do |service_name|
      CreditLogger.warn("Processing daily for workspace #{service_name} for day #{day}")
      Workspace.all.each do |workspace|
        UsageDailyWorkspace.upsert(
          {
            workspace_id: workspace.id,
            day: day,
            service_name: service_name,
            units: all_queries.where(serviceable: workspace, service_name: service_name).count,
            credits: all_queries.where(serviceable: workspace).cost(service_name)
          },
          unique_by: [ :workspace_id, :day, :service_name ]
        )        
      end
    end
  end

  def usage_daily_projects
    Cost.query_service_names.each do |service_name|
      CreditLogger.warn("Processing daily for project #{service_name} for day #{day}")
      Project.all.each do |project|
        all_query_workspaces = ApiQuery.where(date: day.all_day, serviceable: project.workspaces.to_a)
        all_query_project = ApiQuery.where(date: day.all_day, serviceable: project)
        all_query = all_query_workspaces.or(all_query_project)
        UsageDailyProject.upsert(
          {
            project_id: project.id,
            day: day,
            service_name: service_name,
            units: all_query.count,
            credits: all_query.cost(service_name)
          },
          unique_by: [ :project_id, :day, :service_name ]
        )        
      end
    end
  end

  def usage_daily_organizations
    (Cost.query_service_names + Cost.montly_service_names).each do |service_name|
      CreditLogger.warn("Processing daily for organization #{service_name} for day #{day}")
      Organization.all.each do |organization|
        if service_name == "TrustAsset"
          UsageDailyOrganization.upsert(
            {
              organization_id: organization.id,
              day: day,
              service_name: service_name,
              units: organization.trust_assets.count,
              credits: organization.trust_assets.cost
            },
            unique_by: [ :organization_id, :day, :service_name ]
          )
          next
        end
        all_query_workspaces = ApiQuery.where(date: day.all_day, serviceable: organization.workspaces.to_a)
        all_query_projects = ApiQuery.where(date: day.all_day, serviceable: organization.projects.to_a)
        all_query_organization = ApiQuery.where(date: day.all_day, serviceable: organization)
        all_query = all_query_workspaces.or(all_query_projects).or(all_query_organization)
        UsageDailyOrganization.upsert(
          {
            organization_id: organization.id,
            day: day,
            service_name: service_name,
            units: all_query.count,
            credits: all_query.cost(service_name)
          },
          unique_by: [ :organization_id, :day, :service_name ]
        )        
      end
    end
  end

  def usage_daily_account
    (Cost.query_service_names + Cost.montly_service_names).each do |service_name|
      CreditLogger.warn("Processing daily for organization #{service_name} for day #{day}")
      Account.all.each do |account|
        if service_name == "TrustAsset"
          UsageDailyAccount.upsert(
            {
              account_id: account.id,
              day: day,
              service_name: service_name,
              units: account.trust_assets.count,
              credits: account.trust_assets.cost
            },
            unique_by: [ :account_id, :day, :service_name ]
          )
          next
        end
        if service_name == "License"
          UsageDailyAccount.upsert(
            {
              account_id: account.id,
              day: day,
              service_name: service_name,
              units: account.licensees.count,
              credits: account.licensees.cost
            },
            unique_by: [ :account_id, :day, :service_name ]
          )
          next
        end
        all_query_workspaces = ApiQuery.where(date: day.all_day, serviceable: account.workspaces.to_a)
        all_query_projects = ApiQuery.where(date: day.all_day, serviceable: account.projects.to_a)
        all_query_organizations = ApiQuery.where(date: day.all_day, serviceable: account.organizations.to_a)
        all_query = all_query_workspaces.or(all_query_projects).or(all_query_organizations)
        UsageDailyAccount.upsert(
          {
            account_id: account.id,
            day: day,
            service_name: service_name,
            units: all_query.count,
            credits: all_query.cost(service_name)
          },
          unique_by: [ :account_id, :day, :service_name ]
        )        
      end
    end    
  end

  def usage_monthly_account
    Account.all.each do |account|
      trust_assets = account.trust_assets.cost
      licenses = account.licensees.cost
      credits = account.usage_daily_accounts.where(day: day.beginning_of_month..day.end_of_month).where.not(service_name: %w[TrustAsset License]).sum(:credits)
      units = account.trust_assets.count + account.licensees.count + account.usage_daily_accounts.where(day: day.beginning_of_month..day.end_of_month).where.not(service_name: %w[TrustAsset License]).sum(:units)
      UsageMonthlyAccount.upsert(
        {
          account_id: account.id,
          month: day.beginning_of_month,
          units: units,
          credits: credits + trust_assets + licenses
        },
        unique_by: [ :account_id, :month ]
      )
    end    
  end

  def instance_credits
    Cost.query_service_names.each do |service_name|
      CreditLogger.warn("Processing daily for organization #{service_name} for day #{day}")
      InstanceCredit.upsert(
        {
          day: day,
          service_name: service_name,
          credits: UsageDailyOrganization.where(service_name: service_name, day: day.all_day).sum(:credits)
        },
        unique_by: [ :day, :service_name ]
      )  
    end 
  end

  def validate_query
    Cost.query_service_names.each do |service_name|
      CreditLogger.info "Service: #{service_name}".magenta
      # instance_credits = InstanceCredit.where(service_name: service_name).sum(:credits)
      # account_credits = UsageDailyAccount.where(service_name: service_name).sum(:credits)
      # organization_credits = UsageDailyOrganization.where(service_name: service_name).sum(:credits)
      # project_credits = UsageDailyProject.where(service_name: service_name).sum(:credits)
      # workspace_credits = UsageDailyWorkspace.where(service_name: service_name).sum(:credits)

      validate_project(service_name)
      validate_organization(service_name)
      validate_account(service_name)
    end
  end

  def validate_project(service_name)
    Project.all.each do |project|
      sum_project = project.usage_daily_projects.where(service_name: service_name).sum(:credits)
      sum_workspaces = project.workspaces.sum { |w| w.usage_daily_workspaces.where(service_name: service_name).sum(:credits) }
      if sum_project == sum_workspaces
        CreditLogger.warn "Project : ✅ #{project.name} / #{service_name} - #{sum_project}".green
      else
        CreditLogger.warn "Project : ❌ #{project.name} / #{service_name} - (#{sum_project} vs #{sum_workspaces})".red
      end
    end
  end

  def validate_organization(service_name)
    Organization.all.each do |organization|
      sum_organization = organization.usage_daily_organizations.where(service_name: service_name).sum(:credits)
      sum_projects = organization.projects.sum { |w| w.usage_daily_projects.where(service_name: service_name).sum(:credits) }
      if sum_organization == sum_projects
        CreditLogger.warn "Organization : ✅ #{organization.name} / #{service_name} - #{sum_organization}".green
      else
        CreditLogger.warn "Organization : ❌ #{organization.name} / #{service_name} - (#{sum_organization} vs #{sum_projects})".red
      end
    end
  end

  def validate_account(service_name)
    Account.all.each do |account|
      sum_account = account.usage_daily_accounts.where(service_name: service_name).sum(:credits)
      sum_organizations = account.organizations.sum { |w| w.usage_daily_organizations.where(service_name: service_name).sum(:credits) }
      if sum_account == sum_organizations
        CreditLogger.warn "Account : ✅ #{account.name} / #{service_name} - #{sum_account}".green
      else
        CreditLogger.warn "Account : ❌ #{account.name} / #{service_name} - (#{sum_account} vs #{sum_organizations})".red
      end
    end
  end

  def process
    usage_daily_workspaces
    usage_daily_projects
    usage_daily_organizations
    usage_daily_account
    usage_monthly_account
    instance_credits
    validate_query
    processed_date.update(end_at: DateTime.now)
  end
end