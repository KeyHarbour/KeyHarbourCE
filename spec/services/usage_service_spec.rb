require "rails_helper"

RSpec.describe UsageService do
  let(:config) { double("config", secret_key: "test_secret", serveur_url: nil, verify_mode: "OpenSSL::SSL::VERIFY_PEER") }
  let(:service) { described_class.allocate }

  before do
    allow(Rails.application).to receive(:config_for).with("ikigailab").and_return(config)
    service.instance_variable_set(:@config, config)
    service.instance_variable_set(:@timestamp, "1700000000")
  end

  # --- BILLABLE_QUERIES ---
  describe "BILLABLE_QUERIES" do
    it "contains KeyValueStore and Statefile" do
      expect(described_class::BILLABLE_QUERIES).to contain_exactly("KeyValueStore", "Statefile")
    end
  end

  # --- #identity ---
  describe "#identity" do
    let(:tmp_dir) { Dir.mktmpdir }
    let(:storage_dir) { File.join(tmp_dir, "storage") }
    let(:identity_path) { File.join(storage_dir, "identity.yml") }

    before do
      allow(Rails).to receive(:root).and_return(Pathname.new(tmp_dir))
      service.instance_variable_set(:@identity, nil)
    end

    after { FileUtils.rm_rf(tmp_dir) }

    it "generates a uuid and writes identity.yml when file does not exist" do
      result = service.identity
      expect(result["production"]["uuid"]).to be_present
      expect(File.exist?(identity_path)).to be true
    end

    it "loads existing identity from file" do
      FileUtils.mkdir_p(storage_dir)
      existing = { "production" => { "uuid" => "existing-uuid", "host" => nil } }
      File.write(identity_path, existing.to_yaml, encoding: "UTF-8")
      result = service.identity
      expect(result["production"]["uuid"]).to eq("existing-uuid")
    end

    it "memoizes the result" do
      first = service.identity
      expect(first.object_id).to eq(service.identity.object_id)
    end

    it "sets host from ENV['HOST']" do
      allow(ENV).to receive(:[]).with("HOST").and_return("myhost.example.com")
      result = service.identity
      expect(result["production"]["host"]).to eq("myhost.example.com")
    end
  end

  # --- #payload ---
  describe "#payload" do
    let(:account) { build_stubbed(:account, name: "Test Co", country_code: "CA", province_code: "QC", billing_contact: "billing@test.com") }
    let(:daily_scope) { double("daily_scope") }

    before do
      allow(service).to receive(:identity).and_return("production" => { "uuid" => "test-uuid" })
      allow(account).to receive(:usage_daily_accounts).and_return(daily_scope)
      allow(daily_scope).to receive(:where).and_return(daily_scope)
      allow(daily_scope).to receive(:sum).with(:units).and_return(5)
      allow(daily_scope).to receive(:sum).with(:credits).and_return(10.0)
    end

    it "returns valid JSON with instance, instance_usage and account keys" do
      result = JSON.parse(service.payload(account))
      expect(result["instance"]["uuid"]).to eq("test-uuid")
      expect(result["instance_usage"]).to include("date", "queries", "employees")
      expect(result["account"]["name"]).to eq("Test Co")
      expect(result["account"]["country_code"]).to eq("CA")
    end

    it "sets employees from License usage_daily_accounts" do
      result = JSON.parse(service.payload(account))
      expect(result["instance_usage"]["employees"]).to eq(5)
    end

    it "sets queries from query_service_names credits" do
      result = JSON.parse(service.payload(account))
      expect(result["instance_usage"]["queries"]).to eq(10.0)
    end

    it "uses yesterday as the process date" do
      result = JSON.parse(service.payload(account))
      expect(Date.parse(result["instance_usage"]["date"])).to eq(Date.yesterday)
    end
  end

  # --- #signature ---
  describe "#signature" do
    it "returns a 64-char hex string" do
      expect(service.signature("{}")).to match(/\A[0-9a-f]{64}\z/)
    end

    it "changes when payload changes" do
      sig1 = service.signature("{}")
      sig2 = service.signature('{"other":true}')
      expect(sig1).not_to eq(sig2)
    end

    it "changes when timestamp changes" do
      sig1 = service.signature("{}")
      service.instance_variable_set(:@timestamp, "9999999999")
      sig2 = service.signature("{}")
      expect(sig1).not_to eq(sig2)
    end
  end

  # --- #process ---
  describe "#process" do
    context "when serveur_url is nil" do
      it "returns [nil, nil] immediately" do
        expect(service.process).to eq([ nil, nil ])
      end
    end

    context "with a configured server" do
      let(:config_with_url) do
        double("config",
          secret_key: "test_secret",
          serveur_url: "https://api.example.com/usage",
          verify_mode: "OpenSSL::SSL::VERIFY_PEER"
        )
      end
      let(:http)     { double("http") }
      let(:request)  { double("request") }
      let(:response) { double("response", body: '{"status":"ok"}') }
      let(:account)  { build_stubbed(:account) }

      before do
        service.instance_variable_set(:@config, config_with_url)
        allow(Account).to receive(:all).and_return([ account ])
        allow(service).to receive(:payload).and_return("{}")
        allow(service).to receive(:signature).and_return("sig")

        allow(Net::HTTP).to receive(:new).and_return(http)
        allow(http).to receive(:use_ssl=)
        allow(http).to receive(:verify_mode=)
        allow(http).to receive(:request).and_return(response)

        allow(Net::HTTP::Patch).to receive(:new).and_return(request)
        allow(request).to receive(:[]=)
        allow(request).to receive(:body=)
        allow(request).to receive(:body).and_return("{}")
      end

      it "sends a request for each account and returns nil" do
        expect(http).to receive(:request).once
        expect(service.process).to be_nil
      end

      it "sets Content-Type and X-Timestamp headers" do
        expect(request).to receive(:[]=).with("Content-Type", "application/json")
        expect(request).to receive(:[]=).with("X-Timestamp", "1700000000")
        service.process
      end

      it "sets X-Signature per account" do
        expect(request).to receive(:[]=).with("X-Signature", "sig")
        service.process
      end
    end
  end

  # --- .call ---
  describe ".call" do
    it "instantiates the service and calls process" do
      instance = instance_double(described_class, process: nil)
      allow(described_class).to receive(:new).and_return(instance)
      described_class.call
      expect(instance).to have_received(:process)
    end
  end
end
