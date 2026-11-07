require 'rails_helper'

RSpec.describe Member::TeamsController, type: :controller do
  include_context "member_auth"

  let(:team) { teams(:kh_admin_team) }
  let(:team_scope) { Team.unscoped.where(account: accounts(:kh)) }

  before do
    allow(controller).to receive(:datum).and_return(team_scope)
    allow(controller).to receive(:validate_admin?).and_return(true)
  end

  describe "GET #index" do
    before { allow(team_scope).to receive(:search).and_return(team_scope) }

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: team.uuid }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "redirects with notice" do
        post :create, params: { team: { name: "New Team", description: "desc" } }
        expect(response).to redirect_to(member_teams_path)
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid params" do
      it "renders new with unprocessable_entity" do
        post :create, params: { team: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: team.uuid }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update" do
    it "redirects with notice on success" do
      patch :update, params: { id: team.uuid, team: { name: "Updated Team" } }
      expect(response).to redirect_to(member_teams_path)
      expect(flash[:notice]).to be_present
    end
  end

  describe "DELETE #destroy" do
    it "destroys and redirects" do
      delete :destroy, params: { id: team.uuid }
      expect(response).to redirect_to(member_teams_path)
    end
  end
end
