require 'rails_helper'

RSpec.describe Member::OrganizationsController, type: :controller do
  include_context "member_auth"

  let(:organization) { organizations(:infra) }
  let(:org_scope) { Organization.unscoped.where(account: accounts(:kh)) }

  before do
    allow(controller).to receive(:datum).and_return(org_scope)
  end

  describe "GET #index" do
    before { allow(org_scope).to receive(:search).and_return(org_scope) }

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: organization.uuid }
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
      it "redirects to organization" do
        post :create, params: { organization: { name: "New Org", description: "desc" } }
        created = assigns(:item)
        expect(response).to redirect_to(member_organization_path(created))
      end
    end

    context "with invalid params" do
      it "renders new with unprocessable_entity" do
        post :create, params: { organization: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: organization.uuid }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update" do
    it "redirects with notice on success" do
      patch :update, params: { id: organization.uuid, organization: { name: "Updated" } }
      expect(response).to redirect_to(member_organization_path(organization))
      expect(flash[:notice]).to be_present
    end
  end

  describe "DELETE #destroy" do
    it "archives and redirects" do
      delete :destroy, params: { id: organization.uuid }
      expect(response).to redirect_to(member_organizations_path)
    end
  end
end
