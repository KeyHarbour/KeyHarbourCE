require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { users(:chief_executive) }
  let(:valid_password) { "password" }

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with valid credentials" do
      before do
        allow(User).to receive(:authenticate_by).and_return(user)
        allow(user).to receive(:update)
        allow(controller).to receive(:start_new_session_for)
        allow(controller).to receive(:after_authentication_url).and_return(root_path)
      end

      it "redirects after login" do
        post :create, params: { session: { email_address: user.email_address, password: valid_password } }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid credentials" do
      before { allow(User).to receive(:authenticate_by).and_return(nil) }

      it "redirects to login with alert" do
        post :create, params: { session: { email_address: user.email_address, password: "wrong" } }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      allow(controller).to receive(:terminate_session)
      allow(controller).to receive(:authenticated?).and_return(true)
      allow(Current).to receive(:user).and_return(user)
    end

    it "redirects to login" do
      delete :destroy
      expect(response).to redirect_to(new_session_path)
    end
  end
end
