require "rails_helper"

RSpec.describe CreditUsageService do
  let(:day) { Date.today }
  let(:service) { described_class.new(day) }

  before { allow(CreditLogger).to receive(:info).and_return(nil) }

  # --- #initialize ---
  describe "#initialize" do
    it "sets @day when a day is provided" do
      expect(service.day).to eq(day)
    end

    it "calls get_next_date when no day is provided" do
      allow(ProcessedDate).to receive(:all).and_return(double(count: 0))
      allow(ApiQuery).to receive(:order).and_return(double(first: double(date: Date.yesterday)))
      allow(ProcessedDate).to receive(:create_or_find_by).and_return(build(:processed_date))
      allow(CreditLogger).to receive(:warn)
      svc = described_class.new
      expect(svc.day).to be_present
    end
  end

  # --- #get_next_date ---
  describe "#get_next_date" do
    context "when no ProcessedDate exists" do
      before do
        allow(ProcessedDate).to receive(:all).and_return(double(count: 0))
        allow(ApiQuery).to receive(:order).and_return(double(first: double(date: Date.yesterday)))
        allow(ProcessedDate).to receive(:create_or_find_by).and_return(build(:processed_date, day: Date.today))
        allow(CreditLogger).to receive(:warn)
      end

      it "uses the first ApiQuery date" do
        svc = described_class.new
        expect(svc.day).to eq(Date.yesterday)
      end
    end

    context "when ProcessedDate records exist" do
      before do
        allow(ProcessedDate).to receive(:all).and_return(double(count: 1))
        allow(ProcessedDate).to receive(:order).and_return(double(first: double(day: Date.yesterday)))
        allow(ProcessedDate).to receive(:create_or_find_by).and_return(build(:processed_date, day: Date.today))
        allow(CreditLogger).to receive(:warn)
      end

      it "uses the last ProcessedDate day" do
        svc = described_class.new
        expect(svc.day).to eq(Date.yesterday)
      end
    end
  end

  # --- #usage_daily_workspaces ---
  describe "#usage_daily_workspaces" do
    let(:workspace) { build_stubbed(:workspace) }
    let(:queries_scope) { double("queries_scope") }

    before do
      allow(CreditLogger).to receive(:warn)
      allow(Workspace).to receive(:all).and_return([ workspace ])
      allow(ApiQuery).to receive(:where).with(date: day.all_day).and_return(queries_scope)
      allow(queries_scope).to receive(:where).and_return(queries_scope)
      allow(queries_scope).to receive(:count).and_return(2)
      allow(queries_scope).to receive(:cost).and_return(1.5)
      allow(UsageDailyWorkspace).to receive(:upsert)
    end

    it "calls upsert for each service_name" do
      expect(UsageDailyWorkspace).to receive(:upsert).exactly(Cost.query_service_names.size).times
      service.usage_daily_workspaces
    end

    it "upserts with correct keys" do
      expect(UsageDailyWorkspace).to receive(:upsert).with(
        hash_including(workspace_id: workspace.id, day: day, units: 2, credits: 1.5),
        unique_by: [ :workspace_id, :day, :service_name ]
      ).at_least(:once)
      service.usage_daily_workspaces
    end
  end

  # --- #usage_daily_projects ---
  describe "#usage_daily_projects" do
    let(:project) { build_stubbed(:project) }
    let(:queries_scope) { double("queries_scope") }

    before do
      allow(CreditLogger).to receive(:warn)
      allow(Project).to receive(:all).and_return([ project ])
      allow(project).to receive(:workspaces).and_return(double(to_a: []))
      allow(ApiQuery).to receive(:where).and_return(queries_scope)
      allow(queries_scope).to receive(:or).and_return(queries_scope)
      allow(queries_scope).to receive(:count).and_return(3)
      allow(queries_scope).to receive(:cost).and_return(2.0)
      allow(UsageDailyProject).to receive(:upsert)
    end

    it "calls upsert for each service_name" do
      expect(UsageDailyProject).to receive(:upsert).exactly(Cost.query_service_names.size).times
      service.usage_daily_projects
    end
  end

  # --- #usage_daily_organizations ---
  describe "#usage_daily_organizations" do
    let(:organization) { build_stubbed(:organization) }
    let(:queries_scope) { double("queries_scope") }
    let(:trust_assets_scope) { double("trust_assets", count: 1, cost: 0.5) }

    before do
      allow(CreditLogger).to receive(:warn)
      allow(Organization).to receive(:all).and_return([ organization ])
      allow(organization).to receive(:workspaces).and_return(double(to_a: []))
      allow(organization).to receive(:projects).and_return(double(to_a: []))
      allow(organization).to receive(:trust_assets).and_return(trust_assets_scope)
      allow(ApiQuery).to receive(:where).and_return(queries_scope)
      allow(queries_scope).to receive(:or).and_return(queries_scope)
      allow(queries_scope).to receive(:count).and_return(4)
      allow(queries_scope).to receive(:cost).and_return(3.0)
      allow(UsageDailyOrganization).to receive(:upsert)
    end

    it "calls upsert for each service_name (query + monthly)" do
      expected_count = (Cost.query_service_names + Cost.montly_service_names).size
      expect(UsageDailyOrganization).to receive(:upsert).exactly(expected_count).times
      service.usage_daily_organizations
    end

    it "uses trust_assets count and cost for TrustAsset service" do
      expect(UsageDailyOrganization).to receive(:upsert).with(
        hash_including(units: 1, credits: 0.5, service_name: "TrustAsset"),
        unique_by: [ :organization_id, :day, :service_name ]
      )
      service.usage_daily_organizations
    end
  end

  # --- #usage_daily_account ---
  describe "#usage_daily_account" do
    let(:account) { build_stubbed(:account) }
    let(:queries_scope) { double("queries_scope") }
    let(:trust_assets_scope) { double("trust_assets", count: 2, cost: 1.0) }
    let(:licensees_scope) { double("licensees", count: 5, cost: 2.5) }

    before do
      allow(CreditLogger).to receive(:warn)
      allow(Account).to receive(:all).and_return([ account ])
      allow(account).to receive(:workspaces).and_return(double(to_a: []))
      allow(account).to receive(:projects).and_return(double(to_a: []))
      allow(account).to receive(:organizations).and_return(double(to_a: []))
      allow(account).to receive(:trust_assets).and_return(trust_assets_scope)
      allow(account).to receive(:licensees).and_return(licensees_scope)
      allow(ApiQuery).to receive(:where).and_return(queries_scope)
      allow(queries_scope).to receive(:or).and_return(queries_scope)
      allow(queries_scope).to receive(:count).and_return(6)
      allow(queries_scope).to receive(:cost).and_return(4.0)
      allow(UsageDailyAccount).to receive(:upsert)
    end

    it "calls upsert for each service_name (query + monthly)" do
      expected_count = (Cost.query_service_names + Cost.montly_service_names).size
      expect(UsageDailyAccount).to receive(:upsert).exactly(expected_count).times
      service.usage_daily_account
    end

    it "uses trust_assets for TrustAsset service" do
      expect(UsageDailyAccount).to receive(:upsert).with(
        hash_including(units: 2, credits: 1.0, service_name: "TrustAsset"),
        unique_by: [ :account_id, :day, :service_name ]
      )
      service.usage_daily_account
    end

    it "uses licensees for License service" do
      expect(UsageDailyAccount).to receive(:upsert).with(
        hash_including(units: 5, credits: 2.5, service_name: "License"),
        unique_by: [ :account_id, :day, :service_name ]
      )
      service.usage_daily_account
    end
  end

  # --- #usage_monthly_account ---
  describe "#usage_monthly_account" do
    let(:account) { build_stubbed(:account) }
    let(:filtered_scope) { double("filtered_scope") }

    before do
      allow(Account).to receive(:all).and_return([ account ])
      allow(UsageMonthlyAccount).to receive(:upsert)
      allow(account).to receive(:trust_assets).and_return(double(cost: 1.0, count: 2))
      allow(account).to receive(:licensees).and_return(double(cost: 2.0, count: 3))
      allow(account).to receive(:usage_daily_accounts).and_return(
        double("daily_accounts",
          where: double("where_scope",
            where: double("where2_scope",
              not: filtered_scope
            )
          )
        )
      )
      allow(filtered_scope).to receive(:sum).with(:credits).and_return(5.0)
      allow(filtered_scope).to receive(:sum).with(:units).and_return(10)
    end

    it "upserts monthly totals per account" do
      expect(UsageMonthlyAccount).to receive(:upsert).with(
        hash_including(account_id: account.id, month: day.beginning_of_month),
        unique_by: [ :account_id, :month ]
      )
      service.usage_monthly_account
    end
  end

  # --- #instance_credits ---
  describe "#instance_credits" do
    before do
      allow(CreditLogger).to receive(:warn)
      allow(UsageDailyOrganization).to receive_message_chain(:where, :sum).and_return(7.5)
      allow(InstanceCredit).to receive(:upsert)
    end

    it "calls upsert for each query service_name" do
      expect(InstanceCredit).to receive(:upsert).exactly(Cost.query_service_names.size).times
      service.instance_credits
    end

    it "upserts with correct day and service_name" do
      expect(InstanceCredit).to receive(:upsert).with(
        hash_including(day: day, credits: 7.5),
        unique_by: [ :day, :service_name ]
      ).at_least(:once)
      service.instance_credits
    end
  end

  # --- #validate_project / #validate_organization / #validate_account ---
  describe "#validate_project" do
    let(:project) { build_stubbed(:project) }

    before do
      allow(Project).to receive(:all).and_return([ project ])
      allow(CreditLogger).to receive(:warn)
    end

    it "logs success when project sum equals workspace sum" do
      allow(project).to receive_message_chain(:usage_daily_projects, :where, :sum).and_return(10)
      allow(project).to receive(:workspaces).and_return([ double(usage_daily_workspaces: double(where: double(sum: 10))) ])
      expect(CreditLogger).to receive(:warn).with(include("✅"))
      service.validate_project("KeyValueStore")
    end

    it "logs failure when sums differ" do
      allow(project).to receive_message_chain(:usage_daily_projects, :where, :sum).and_return(10)
      allow(project).to receive(:workspaces).and_return([ double(usage_daily_workspaces: double(where: double(sum: 5))) ])
      expect(CreditLogger).to receive(:warn).with(include("❌"))
      service.validate_project("KeyValueStore")
    end
  end

  describe "#validate_organization" do
    let(:organization) { build_stubbed(:organization) }
    let(:project_double) { double("project", usage_daily_projects: double(where: double(sum: 10))) }

    before do
      allow(Organization).to receive(:all).and_return([ organization ])
      allow(CreditLogger).to receive(:warn)
      allow(organization).to receive_message_chain(:usage_daily_organizations, :where, :sum).and_return(10)
      allow(organization).to receive(:projects).and_return([ project_double ])
    end

    it "logs success when sums match" do
      expect(CreditLogger).to receive(:warn).with(include("✅"))
      service.validate_organization("KeyValueStore")
    end
  end

  describe "#validate_account" do
    let(:account) { build_stubbed(:account) }
    let(:org_double) { double("org", usage_daily_organizations: double(where: double(sum: 10))) }

    before do
      allow(Account).to receive(:all).and_return([ account ])
      allow(CreditLogger).to receive(:warn)
      allow(account).to receive_message_chain(:usage_daily_accounts, :where, :sum).and_return(10)
      allow(account).to receive(:organizations).and_return([ org_double ])
    end

    it "logs success when sums match" do
      expect(CreditLogger).to receive(:warn).with(include("✅"))
      service.validate_account("KeyValueStore")
    end
  end

  # --- #process ---
  describe "#process" do
    let(:processed_date) { create(:processed_date, day: day) }

    before do
      service.instance_variable_set(:@processed_date, processed_date)
      allow(service).to receive(:usage_daily_workspaces)
      allow(service).to receive(:usage_daily_projects)
      allow(service).to receive(:usage_daily_organizations)
      allow(service).to receive(:usage_daily_account)
      allow(service).to receive(:usage_monthly_account)
      allow(service).to receive(:instance_credits)
      allow(service).to receive(:validate_query)
    end

    it "calls all sub-methods and updates processed_date end_at" do
      expect(service).to receive(:usage_daily_workspaces)
      expect(service).to receive(:usage_daily_projects)
      expect(service).to receive(:usage_daily_organizations)
      expect(service).to receive(:usage_daily_account)
      expect(service).to receive(:usage_monthly_account)
      expect(service).to receive(:instance_credits)
      expect(service).to receive(:validate_query)
      service.process
      expect(processed_date.reload.end_at).to be_present
    end
  end
end
