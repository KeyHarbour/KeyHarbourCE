require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  # --- renewal_color ---
  describe "#renewal_color" do
    let(:item) { double("item") }

    it "returns red for level 0" do
      allow(item).to receive(:renewal_level).and_return(0)
      expect(helper.renewal_color(item)).to eq("bg-red kh_white")
    end

    it "returns yellow for level 1" do
      allow(item).to receive(:renewal_level).and_return(1)
      expect(helper.renewal_color(item)).to eq("bg-yellow kh_white")
    end

    it "returns primary for level 2" do
      allow(item).to receive(:renewal_level).and_return(2)
      expect(helper.renewal_color(item)).to eq("bg-primary kh_white")
    end

    it "returns green for level 3+" do
      allow(item).to receive(:renewal_level).and_return(3)
      expect(helper.renewal_color(item)).to eq("bg-green kh_white")
    end
  end

  # --- status_color ---
  describe "#status_color" do
    let(:item) { double("item") }

    it "returns green when active" do
      allow(item).to receive(:active?).and_return(true)
      allow(item).to receive(:disabled?).and_return(false)
      expect(helper.status_color(item)).to eq("bg-green")
    end

    it "returns yellow when disabled" do
      allow(item).to receive(:active?).and_return(false)
      allow(item).to receive(:disabled?).and_return(true)
      expect(helper.status_color(item)).to eq("bg-yellow")
    end

    it "returns red when archived" do
      allow(item).to receive(:active?).and_return(false)
      allow(item).to receive(:disabled?).and_return(false)
      expect(helper.status_color(item)).to eq("bg-red")
    end
  end

  # --- flash_class ---
  describe "#flash_class" do
    it "returns green for :notice" do
      expect(helper.flash_class(:notice)).to eq("bg-green-600 border-green-700")
    end

    it "returns red for :alert" do
      expect(helper.flash_class(:alert)).to eq("bg-red-600 border-red-700")
    end

    it "returns red for :error" do
      expect(helper.flash_class(:error)).to eq("bg-red-600 border-red-700")
    end

    it "returns blue for unknown type" do
      expect(helper.flash_class(:info)).to eq("bg-blue-600 border-blue-700")
    end
  end

  # --- bg_color ---
  describe "#bg_color" do
    it "returns red-100 for level 0" do
      expect(helper.bg_color(0)).to eq("bg-red-100")
    end

    it "returns orange-100 for level 1" do
      expect(helper.bg_color(1)).to eq("bg-orange-100")
    end

    it "returns blue-100 for level 2" do
      expect(helper.bg_color(2)).to eq("bg-blue-100")
    end

    it "returns green-100 for level 3+" do
      expect(helper.bg_color(3)).to eq("bg-green-100")
      expect(helper.bg_color(99)).to eq("bg-green-100")
    end

    it "handles string input" do
      expect(helper.bg_color("0")).to eq("bg-red-100")
      expect(helper.bg_color("2")).to eq("bg-blue-100")
    end
  end

  # --- langs ---
  describe "#langs" do
    it "returns en and fr entries" do
      expect(helper.langs.keys).to contain_exactly(:en, :fr)
    end

    it "has name and flag for each lang" do
      helper.langs.each_value do |v|
        expect(v).to include(:name, :flag)
      end
    end
  end

  # --- province_options ---
  describe "#province_options" do
    it "returns an array of [name, code] pairs for CA" do
      result = helper.province_options("CA")
      expect(result).to be_an(Array)
      expect(result.first).to be_an(Array)
      expect(result.first.size).to eq(2)
    end

    it "returns an array for US" do
      result = helper.province_options("US")
      expect(result).not_to be_empty
    end

    it "returns empty array for unknown country" do
      expect(helper.province_options("ZZ")).to eq([])
    end
  end

  # --- level1_active? ---
  describe "#level1_active?" do
    it "returns 'here show' when item is active" do
      expect(helper.level1_active?({ active: true })).to eq("here show")
    end

    it "returns empty string when item is not active" do
      expect(helper.level1_active?({ active: false })).to eq("")
      expect(helper.level1_active?({})).to eq("")
    end
  end

  # --- show_menu_item? ---
  describe "#show_menu_item?" do
    before { allow(helper).to receive(:request).and_return(double(path: "/member/organizations")) }

    it "returns 'show' when item is active" do
      expect(helper.show_menu_item?({ active: true })).to eq("show")
    end

    it "returns 'show' when request path matches start_with" do
      expect(helper.show_menu_item?({ start_with: "/member" })).to eq("show")
    end

    it "returns 'show' when a sub_item path matches request path" do
      expect(helper.show_menu_item?({ items: [ { link: "/member/organizations" } ] })).to eq("show")
    end

    it "returns empty string when nothing matches" do
      expect(helper.show_menu_item?({ items: [ { link: "/admin" } ] })).to eq("")
    end
  end

  # --- sub_menu_active? ---
  describe "#sub_menu_active?" do
    before { allow(helper).to receive(:request).and_return(double(path: "/member/teams")) }

    it "returns 'active' when item has active: true" do
      expect(helper.sub_menu_active?({ active: true })).to eq("active")
    end

    it "returns '' when item has active: false" do
      expect(helper.sub_menu_active?({ active: false })).to eq("")
    end

    it "returns 'active' when request path matches link" do
      expect(helper.sub_menu_active?({ link: "/member/teams" })).to eq("active")
    end

    it "returns '' when nothing matches" do
      expect(helper.sub_menu_active?({ link: "/admin" })).to eq("")
    end
  end

  # --- controller_items ---
  describe "#controller_items" do
    it "returns the CONTROLLERS hash" do
      expect(helper.controller_items).to eq(ApplicationHelper::CONTROLLERS)
    end

    it "includes member/dashboard" do
      expect(helper.controller_items[:"member/dashboard"]).to include(:title, :icon)
    end

    it "includes admin/accounts" do
      expect(helper.controller_items[:"admin/accounts"]).to include(:title, :icon)
    end
  end

  # --- search / step_back / display_back ---
  describe "simple boolean helpers" do
    it "#search returns false" do
      expect(helper.search).to eq(false)
    end

    it "#step_back returns false" do
      expect(helper.step_back).to eq(false)
    end

    it "#display_back returns false" do
      expect(helper.display_back).to eq(false)
    end
  end
end
