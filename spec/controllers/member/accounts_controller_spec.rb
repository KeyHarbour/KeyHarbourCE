require 'rails_helper'

RSpec.describe Member::AccountsController, type: :controller do
  include_context "member_auth"

  before do
    allow(controller).to receive(:datum).and_return(Account)
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "redirects to member root with notice" do
        post :create, params: { account: { name: "New Account", billing_contact: "billing@example.com", country_code: "CA", province_code: "QC" } }
        expect(response).to redirect_to(member_root_path)
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid params" do
      it "renders new with unprocessable_entity" do
        post :create, params: { account: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
