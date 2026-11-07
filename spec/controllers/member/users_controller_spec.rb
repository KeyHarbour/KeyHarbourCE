require 'rails_helper'

RSpec.describe Member::UsersController, type: :controller do
  include_context "member_auth"

  let(:target_user) { users(:chief_technology) }
  let(:user_scope) { User.joins(:account_user).where(account_users: { account_id: accounts(:kh).id }) }

  before do
    allow(controller).to receive(:datum).and_return(user_scope)
    allow(controller).to receive(:validate_admin?).and_return(true)
  end

  describe "GET #index" do
    before { allow(user_scope).to receive(:search).and_return(user_scope) }

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: target_user.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: target_user.id }
      expect(response).to have_http_status(:success)
    end
  end
end
