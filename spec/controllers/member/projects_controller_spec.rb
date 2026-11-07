require 'rails_helper'

RSpec.describe Member::ProjectsController, type: :controller do
  include_context "member_auth"

  let(:organization) { organizations(:infra) }
  let(:project) { projects(:security) }
  let(:project_scope) { Project.unscoped.where(organization: organization) }

  before do
    allow(controller).to receive(:datum).and_return(project_scope)
    allow(controller).to receive(:set_items).and_wrap_original do |_m|
      controller.instance_variable_set(:@organization, organization)
    end
  end

  describe "GET #index" do
    before { allow(project_scope).to receive(:search).and_return(project_scope) }

    it "returns http success" do
      get :index, params: { organization_id: organization.uuid }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: project.uuid }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new, params: { organization_id: organization.uuid }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "redirects to project" do
        post :create, params: { organization_id: organization.uuid, project: { name: "New Project", description: "desc" } }
        expect(response).to redirect_to(member_project_path(assigns(:item)))
      end
    end

    context "with invalid params" do
      it "renders new with unprocessable_entity" do
        post :create, params: { organization_id: organization.uuid, project: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: project.uuid }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update" do
    it "redirects with notice on success" do
      patch :update, params: { id: project.uuid, project: { name: "Updated" } }
      expect(response).to redirect_to(member_project_path(project))
      expect(flash[:notice]).to be_present
    end
  end
end
