require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe ".all" do
    it "returns a non-empty list of plans" do
      expect(Plan.all).not_to be_empty
    end

    it "returns Plan instances" do
      expect(Plan.all).to all(be_a(Plan))
    end
  end

  describe ".find" do
    it "returns the plan with the given id" do
      plan = Plan.find("free")
      expect(plan.id).to eq("free")
    end

    it "raises RecordNotFound for unknown id" do
      expect { Plan.find("nonexistent") }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe ".where" do
    it "filters plans by attribute" do
      results = Plan.where(id: "free")
      expect(results.map(&:id)).to eq(["free"])
    end
  end

  describe "attributes" do
    subject(:plan) { Plan.find("free") }

    it "has a price" do
      expect(plan.price).to be_a(Numeric)
    end

    it "has credits" do
      expect(plan.credits).to be_a(Integer)
    end

    it "has an order" do
      expect(plan.order).to be_a(Integer)
    end
  end

  describe "#full_name" do
    it "prefixes name with KH -" do
      plan = Plan.find("free")
      expect(plan.full_name).to start_with("KH - ")
    end
  end

  describe "#name" do
    it "delegates to I18n" do
      plan = Plan.find("free")
      expect(I18n).to receive(:t).with("member.pricings.index.plans.free.name").and_return("Free")
      expect(plan.name).to eq("Free")
    end
  end

  describe "#description" do
    it "delegates to I18n" do
      plan = Plan.find("free")
      expect(I18n).to receive(:t).with("member.pricings.index.plans.free.description").and_return("Free plan")
      expect(plan.description).to eq("Free plan")
    end
  end

  describe ".all memoization" do
    it "returns the same object on repeated calls" do
      Plan.instance_variable_set(:@all, nil)
      first = Plan.all
      second = Plan.all
      expect(first.object_id).to eq(second.object_id)
    end
  end

  describe ".where" do
    it "returns empty array when no plan matches" do
      expect(Plan.where(id: "nonexistent")).to eq([])
    end

    it "filters by boolean attribute" do
      results = Plan.where(available: true)
      expect(results).to all(have_attributes(available: true))
    end
  end

  describe "Stripe methods" do
    let(:plan) { Plan.find("free") }
    let(:stripe_client) { double("stripe_client") }
    let(:v1) { double("v1") }
    let(:products_api) { double("products_api") }
    let(:prices_api) { double("prices_api") }
    let(:meters_api) { double("meters_api") }
    let(:billing_api) { double("billing_api") }

    before do
      Plan.instance_variable_set(:@client, stripe_client)
      Plan.instance_variable_set(:@products, nil)
      allow(stripe_client).to receive(:v1).and_return(v1)
      allow(v1).to receive(:products).and_return(products_api)
      allow(v1).to receive(:prices).and_return(prices_api)
      allow(v1).to receive(:billing).and_return(billing_api)
      allow(billing_api).to receive(:meters).and_return(meters_api)
    end

    describe "#product_exists_in_stripe?" do
      it "returns existing product id when name matches" do
        allow(products_api).to receive(:list).and_return(double(data: [ { "id" => "prod_123", "name" => plan.full_name } ]))
        expect(plan.product_exists_in_stripe?).to eq("prod_123")
      end

      it "creates a new product when not found" do
        allow(products_api).to receive(:list).and_return(double(data: []))
        allow(products_api).to receive(:create).and_return({ "id" => "prod_new" })
        expect(plan.product_exists_in_stripe?).to eq("prod_new")
      end
    end

    describe "#price_id?" do
      it "returns price id when nickname matches" do
        allow(prices_api).to receive(:list).and_return([ { "id" => "price_123", "nickname" => "Free - Month" } ])
        expect(plan.price_id?("Free - Month")).to eq("price_123")
      end

      it "returns nil when nickname not found" do
        allow(prices_api).to receive(:list).and_return([])
        expect(plan.price_id?("Nonexistent")).to be_nil
      end
    end

    describe "#meter_exists_in_stripe?" do
      it "returns existing meter id when event_name matches" do
        allow(meters_api).to receive(:list).and_return(double(data: [ { "id" => "meter_123", "event_name" => "credit" } ]))
        expect(plan.meter_exists_in_stripe?).to eq("meter_123")
      end

      it "creates a new meter when not found" do
        allow(meters_api).to receive(:list).and_return(double(data: []))
        allow(meters_api).to receive(:create).and_return({ "id" => "meter_new" })
        expect(plan.meter_exists_in_stripe?).to eq("meter_new")
      end
    end

    describe "#create_price" do
      before { allow(plan).to receive(:price_id?).and_return(nil) }

      it "skips creation when price already exists" do
        allow(plan).to receive(:price_id?).and_return("price_existing")
        expect(prices_api).not_to receive(:create)
        plan.create_price("prod_123", nil, "month", 0)
      end

      it "creates a price when it does not exist" do
        allow(prices_api).to receive(:create).and_return({ "id" => "price_new" })
        plan.create_price("prod_123", nil, "month", 1000)
        expect(prices_api).to have_received(:create).with(hash_including(
          currency: "cad",
          unit_amount: 1000,
          recurring: hash_including(interval: "month")
        ))
      end
    end

    describe "#prices" do
      it "skips when plan price is 0" do
        allow(plan).to receive(:price).and_return(0)
        expect(plan).not_to receive(:create_price)
        plan.prices("prod_123")
      end

      it "creates month and year prices when price > 0" do
        allow(plan).to receive(:price).and_return(BigDecimal("10"))
        allow(plan).to receive(:price_annual).and_return(BigDecimal("100"))
        expect(plan).to receive(:create_price).with("prod_123", nil, "month", 1000)
        expect(plan).to receive(:create_price).with("prod_123", nil, "year", 10000)
        plan.prices("prod_123")
      end
    end

    describe "#sync_with_stripe" do
      it "calls product_exists_in_stripe? and prices" do
        allow(plan).to receive(:product_exists_in_stripe?).and_return("prod_123")
        expect(plan).to receive(:prices).with("prod_123")
        plan.sync_with_stripe
      end
    end
  end
end
