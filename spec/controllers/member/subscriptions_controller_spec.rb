require 'rails_helper'

RSpec.describe Member::SubscriptionsController, type: :controller do
  include_context "member_auth"

  let(:subscription) { double("subscription", id: 1) }

  before do
    allow(Current).to receive(:subscription).and_return(subscription)
    allow(controller).to receive(:validate_admin?).and_return(true)
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "assigns subscription" do
      get :index
      expect(assigns(:subscription)).to eq(subscription)
    end
  end

  describe "GET #fail" do
    before { allow(Notification).to receive(:create!) }

    it "renders index" do
      get :fail, params: { id: subscription.id }
      expect(response).to have_http_status(:success)
    end
  end
end
