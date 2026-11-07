require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  before do
    allow(controller).to receive(:allow_public?).and_return(true)
    allow(KeyHarbour).to receive(:allow_public?).and_return(true)
    allow(KeyHarbour).to receive(:multi_account?).and_return(false)
    allow(controller).to receive(:multi_account?).and_return(false)
    allow(controller).to receive(:log_history)
    allow(controller).to receive(:check_password_change)
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      { user: { email_address: "new@example.com", password: "password123!", password_confirmation: "password123!" } }
    end

    context "with valid params" do
      before do
        allow_any_instance_of(User).to receive(:save).and_return(true)
        allow(controller).to receive(:start_new_session_for)
        allow(Account).to receive(:first).and_return(accounts(:kh))
        allow(Role).to receive(:find_by).and_return(roles(:inactive))
      end

      it "redirects to root" do
        post :create, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid params" do
      before { allow_any_instance_of(User).to receive(:save).and_return(false) }

      it "renders new with unprocessable_entity" do
        post :create, params: { user: { email_address: "", password: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
