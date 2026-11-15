require "rails_helper"
require "registration/register"

RSpec.describe Registration::Register do
  let(:register) { described_class.allocate } # bypass initialize

  before do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("test"))
    register.instance_variable_set(:@features, {})
    register.instance_variable_set(:@timestamp, Time.now.to_i.to_s)
  end

  # --- #features ---
  describe "#features" do
    it "returns the @features array" do
      register.instance_variable_set(:@features, { "terraform" => true })
      expect(register.features).to eq({ "terraform" => true })
    end
  end

  # --- #feature ---
  describe "#feature" do
    it "returns false when features is empty" do
      register.instance_variable_set(:@features, [])
      expect(register.feature(:terraform)).to be false
    end

    it "returns false when feature is present but value is not true" do
      register.instance_variable_set(:@features, { "terraform" => false })
      expect(register.feature(:terraform)).to be false
    end

    it "returns false when feature is not in the hash" do
      register.instance_variable_set(:@features, { "other" => true })
      expect(register.feature(:terraform)).to be false
    end
  end

  # --- #license_file_name ---
  describe "#license_file_name" do
    it "returns a path ending with storage/license.enc" do
      expect(register.license_file_name.to_s).to end_with("storage/license.enc")
    end
  end

  # --- #identity ---
  describe "#identity" do
    let(:tmp_dir) { Dir.mktmpdir }
    let(:storage_dir) { File.join(tmp_dir, "storage") }
    let(:identity_path) { File.join(storage_dir, "identity.yml") }

    before do
      allow(Rails).to receive(:root).and_return(Pathname.new(tmp_dir))
      register.instance_variable_set(:@identity, nil)
    end

    after { FileUtils.rm_rf(tmp_dir) }

    it "generates a uuid and writes identity.yml when file does not exist" do
      result = register.identity
      expect(result["production"]["uuid"]).to be_present
      expect(File.exist?(identity_path)).to be true
    end

    it "loads existing identity from file" do
      FileUtils.mkdir_p(storage_dir)
      existing = { "production" => { "uuid" => "existing-uuid", "host" => nil } }
      File.write(identity_path, existing.to_yaml, encoding: "UTF-8")
      result = register.identity
      expect(result["production"]["uuid"]).to eq("existing-uuid")
    end

    it "memoizes the result" do
      first = register.identity
      second = register.identity
      expect(first.object_id).to eq(second.object_id)
    end

    it "sets host from ENV['HOST']" do
      allow(ENV).to receive(:[]).with("HOST").and_return("myhost.example.com")
      result = register.identity
      expect(result["production"]["host"]).to eq("myhost.example.com")
    end
  end

  # --- #safe_count ---
  describe "#safe_count" do
    it "returns nil for an unknown model" do
      expect(register.safe_count("NonExistentModel123")).to be_nil
    end

    it "returns a count for a valid model" do
      allow(User).to receive(:all).and_return(double(count: 5))
      expect(register.safe_count("User")).to eq(5)
    end

    it "returns nil on ActiveRecord::NoDatabaseError" do
      allow(User).to receive(:all).and_raise(ActiveRecord::NoDatabaseError)
      expect(register.safe_count("User")).to be_nil
    end
  end

  # --- #payload ---
  describe "#payload" do
    before do
      allow(register).to receive(:identity).and_return(
        "production" => { "uuid" => "test-uuid", "host" => "localhost" }
      )
      allow(register).to receive(:system_machine_id).and_return("machine-123")
      allow(register).to receive(:safe_count).and_return(0)
      allow(Rails.configuration).to receive(:version).and_return("1.0.0\n")
    end

    it "returns valid JSON with instance keys" do
      result = JSON.parse(register.payload)
      expect(result["instance"]["uuid"]).to eq("test-uuid")
      expect(result["instance"]["url"]).to eq("localhost")
      expect(result["instance"]["version"]).to eq("1.0.0")
      expect(result["instance"]).to include("users", "organizations", "projects", "workspaces")
    end
  end

  # --- #signature ---
  describe "#signature" do
    before do
      config = double(secret_key: "mysecret", serveur_url: nil, verify_mode: "OpenSSL::SSL::VERIFY_PEER")
      register.instance_variable_set(:@config, config)
      allow(register).to receive(:payload).and_return('{"instance":{}}')
    end

    it "returns a hex string" do
      expect(register.signature).to match(/\A[0-9a-f]{64}\z/)
    end

    it "changes when timestamp changes" do
      sig1 = register.signature
      register.instance_variable_set(:@timestamp, (Time.now.to_i + 1).to_s)
      sig2 = register.signature
      expect(sig1).not_to eq(sig2)
    end
  end

  # --- #read_license ---
  describe "#read_license" do
    let(:tmp_dir) { Dir.mktmpdir }

    before do
      allow(Rails).to receive(:root).and_return(Pathname.new(tmp_dir))
      register.instance_variable_set(:@license, nil)
      allow(register).to receive(:identity).and_return("production" => { "uuid" => "test-uuid" })
    end

    after { FileUtils.rm_rf(tmp_dir) }

    it "returns empty hash when license file does not exist" do
      expect(register.read_license).to eq({})
    end

    it "returns memoized license on second call" do
      register.instance_variable_set(:@license, { "shared" => {} })
      expect(register.read_license).to eq({ "shared" => {} })
    end
  end

  # --- #write_license / #read_license round-trip ---
  describe "#write_license and #read_license" do
    let(:tmp_dir) { Dir.mktmpdir }
    let(:content) { { "shared" => { "features" => { "terraform" => true } } } }

    before do
      allow(Rails).to receive(:root).and_return(Pathname.new(tmp_dir))
      allow(register).to receive(:identity).and_return("production" => { "uuid" => "test-uuid" })
    end

    after { FileUtils.rm_rf(tmp_dir) }

    it "writes and reads back the license correctly" do
      register.write_license(content)
      register.instance_variable_set(:@license, nil)
      result = register.read_license
      expect(result["shared"]["features"]["terraform"]).to be true
    end
  end

  # --- #process ---
  describe "#process" do
    before do
      config = double(secret_key: "s", serveur_url: nil, verify_mode: "OpenSSL::SSL::VERIFY_PEER")
      register.instance_variable_set(:@config, config)
    end

    it "returns [nil, nil] when serveur_url is nil" do
      expect(register.process).to eq([ nil, nil ])
    end

    context "with a valid server response" do
      let(:response_body) { { "licence_id" => "lic-123", "features" => [ "terraform" ] }.to_json }
      let(:http_response) { double(body: response_body) }
      let(:http) { double(use_ssl: nil, verify_mode: nil, open_timeout: nil, read_timeout: nil, write_timeout: nil) }
      let(:request) { double(:[]=, body: nil) }

      before do
        config = double(
          secret_key: "s",
          serveur_url: "https://api.example.com/register",
          verify_mode: "OpenSSL::SSL::VERIFY_PEER"
        )
        register.instance_variable_set(:@config, config)
        allow(register).to receive(:identity).and_return("production" => { "uuid" => "uuid" })
        allow(register).to receive(:payload).and_return("{}")
        allow(register).to receive(:signature).and_return("sig")

        allow(Net::HTTP).to receive(:new).and_return(http)
        allow(http).to receive(:use_ssl=)
        allow(http).to receive(:verify_mode=)
        allow(http).to receive(:open_timeout=)
        allow(http).to receive(:read_timeout=)
        allow(http).to receive(:write_timeout=)
        allow(http).to receive(:request).and_return(http_response)
        allow(Net::HTTP::Post).to receive(:new).and_return(request)
        allow(request).to receive(:[]=)
        allow(request).to receive(:body=)
      end

      it "returns licence_id and features from response" do
        licence_id, features = register.process
        expect(licence_id).to eq("lic-123")
        expect(features).to eq([ "terraform" ])
      end
    end

    context "on timeout" do
      before do
        config = double(
          secret_key: "s",
          serveur_url: "https://api.example.com/register",
          verify_mode: "OpenSSL::SSL::VERIFY_PEER"
        )
        register.instance_variable_set(:@config, config)
        allow(register).to receive(:identity).and_return("production" => { "uuid" => "uuid" })
        allow(register).to receive(:payload).and_return("{}")
        allow(register).to receive(:signature).and_return("sig")

        http = double
        allow(Net::HTTP).to receive(:new).and_return(http)
        allow(http).to receive(:use_ssl=)
        allow(http).to receive(:verify_mode=)
        allow(http).to receive(:open_timeout=)
        allow(http).to receive(:read_timeout=)
        allow(http).to receive(:write_timeout=)
        allow(http).to receive(:request).and_raise(Net::OpenTimeout)
        request = double("request")
        allow(request).to receive(:[]=)
        allow(request).to receive(:body=)
        allow(Net::HTTP::Post).to receive(:new).and_return(request)
      end

      it "handles timeout gracefully without raising" do
        expect { register.process }.not_to raise_error
      end
    end
  end
end
