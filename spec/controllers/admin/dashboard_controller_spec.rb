require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  let(:admin_user) { users(:chief_executive) }

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

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  context "when user is not admin" do
    before { allow(admin_user).to receive(:admin?).and_return(false) }

    it "redirects to root" do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end
end
