require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin_user) { users(:chief_executive) }
  let(:target_user) { users(:chief_technology) }

  before do
    session_record = Session.create!(user: admin_user)
    allow(Current).to receive(:session).and_return(session_record)
    allow(Current).to receive(:user).and_return(admin_user)
    allow(admin_user).to receive(:admin?).and_return(true)
    allow(controller).to receive(:log_history)
    allow(controller).to receive(:enforce_custom_permissions!)
    allow(controller).to receive(:set_locale)
    allow(controller).to receive(:set_items)
    allow(controller).to receive(:set_organization)
    allow(controller).to receive(:set_parent_obj)
    allow(controller).to receive(:validate_organization)
    allow(controller).to receive(:set_parent_item)
    cookies.signed[:session_id] = session_record.id
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: target_user.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update" do
    before do
      allow(controller).to receive(:datum).and_return(User)
      allow(controller).to receive(:back_path).and_return(admin_users_path)
    end

    context "with valid params" do
      it "redirects with notice" do
        patch :update, params: { id: target_user.id, user: { email_address: target_user.email_address } }
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to be_present
      end
    end
  end

  context "when user is not admin" do
    before { allow(admin_user).to receive(:admin?).and_return(false) }

    it "redirects to root on index" do
      get :show, params: { id: target_user.id }
      expect(response).to redirect_to(root_path)
    end
  end
end
