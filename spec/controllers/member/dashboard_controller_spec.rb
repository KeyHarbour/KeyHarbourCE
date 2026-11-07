require 'rails_helper'

RSpec.describe Member::DashboardController, type: :controller do
  include_context "member_auth"

  before do
    usage_scope = double("usage_scope")
    allow(usage_scope).to receive(:where).and_return(usage_scope)
    allow(usage_scope).to receive(:sum).and_return(0)
    allow(usage_scope).to receive(:maximum).and_return(0)
    allow(account).to receive(:usage_daily_accounts).and_return(usage_scope)
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "assigns billing range" do
      get :index
      expect(assigns(:days_range)).to be_present
    end
  end
end
