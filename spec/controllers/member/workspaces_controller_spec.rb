require 'rails_helper'

RSpec.describe Member::WorkspacesController, type: :controller do
  include_context "member_auth"

  let(:project) { projects(:kh_nexus) }
  let(:workspace) { workspaces(:infra_nexus) }
  let(:workspace_scope) { Workspace.unscoped.where(project: project) }

  before do
    allow(controller).to receive(:datum).and_return(workspace_scope)
    allow(controller).to receive(:set_items).and_wrap_original do |_m|
      controller.instance_variable_set(:@project, project)
      controller.instance_variable_set(:@organization, project.organization)
    end
  end

  describe "GET #index" do
    before { allow(workspace_scope).to receive(:search).and_return(workspace_scope) }

    it "returns http success" do
      get :index, params: { project_id: project.uuid }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: workspace.uuid }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new, params: { project_id: project.uuid }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "redirects to workspace" do
        post :create, params: { project_id: project.uuid, workspace: { name: "New WS", description: "desc" } }
        expect(response).to redirect_to(member_project_workspaces_path(project))
      end
    end

    context "with invalid params" do
      it "renders new with unprocessable_entity" do
        post :create, params: { project_id: project.uuid, workspace: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: workspace.uuid }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update" do
    it "redirects with notice on success" do
      patch :update, params: { id: workspace.uuid, workspace: { name: "Updated" } }
      expect(response).to redirect_to(member_project_workspaces_path(project))
      expect(flash[:notice]).to be_present
    end
  end

  # describe "PUT #activate" do
  #   it "activates and redirects back" do
  #     put :activate, params: { id: workspace.uuid }
  #     expect(response).to redirect_to(root_path)
  #   end
  # end

  # describe "PUT #unactivate" do
  #   it "disables and redirects back" do
  #     put :unactivate, params: { id: workspace.uuid }
  #     expect(response).to redirect_to(root_path)
  #   end
  # end
end
