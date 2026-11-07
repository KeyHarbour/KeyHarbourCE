require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  let(:user) { users(:chief_executive) }

  before do
    allow(controller).to receive(:log_history)
    allow(controller).to receive(:check_password_change)
    allow(controller).to receive(:enforce_custom_permissions!)
    allow(controller).to receive(:set_locale)
    allow(controller).to receive(:set_items)
    allow(controller).to receive(:set_organization)
    allow(controller).to receive(:set_parent_obj)
    allow(controller).to receive(:validate_organization)
    allow(controller).to receive(:set_parent_item)
    allow(controller).to receive(:set_breadcrumbs)
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "when user exists" do
      before { allow(User).to receive(:find_by).and_return(user) }

      it "sends reset email and redirects" do
        expect(PasswordsMailer).to receive(:reset).with(user).and_return(double(deliver_later: true))
        post :create, params: { email_address: user.email_address }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to be_present
      end
    end

    context "when user does not exist" do
      before { allow(User).to receive(:find_by).and_return(nil) }

      it "still redirects without error (security)" do
        post :create, params: { email_address: "unknown@example.com" }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "PATCH #update" do
    let(:token) { "valid_token" }

    before do
      allow(User).to receive(:find_by_password_reset_token!).and_return(user)
    end

    context "with matching passwords" do
      before { allow(user).to receive(:update).and_return(true) }

      it "redirects to login with notice" do
        patch :update, params: { token: token, password: "newpass123!", password_confirmation: "newpass123!" }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to be_present
      end
    end

    context "with non-matching passwords" do
      before { allow(user).to receive(:update).and_return(false) }

      it "redirects back with alert" do
        patch :update, params: { token: token, password: "newpass123!", password_confirmation: "different!" }
        expect(response).to redirect_to(edit_password_path(token))
        expect(flash[:alert]).to be_present
      end
    end
  end
end
