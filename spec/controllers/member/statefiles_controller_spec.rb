require "rails_helper"

RSpec.describe Member::StatefilesController, type: :controller do
  include_context "member_auth"

  let(:workspace)    { workspaces(:infra_nexus) }
  let(:environment)  { environments(:sandbox_kh) }
  let(:statefile)    { statefiles(:infra_nexus_sbx1) }
  let(:datum_scope)  { workspace.statefiles.where(environment: environment) }

  before do
    allow(controller).to receive(:set_items).and_wrap_original do |_m|
      controller.instance_variable_set(:@workspace, workspace)
      controller.instance_variable_set(:@environment, environment)
      controller.instance_variable_set(:@item, statefile)
      controller.instance_variable_set(:@statefile, statefile)
      controller.instance_variable_set(:@project, workspace.project)
      controller.instance_variable_set(:@organization, workspace.project.organization)
    end
    allow(controller).to receive(:datum).and_return(datum_scope)
  end

  # --- GET #index ---
  describe "GET #index" do
    it "returns http success" do
      get :index, params: { workspace_id: workspace.uuid, environment: environment.name }
      expect(response).to have_http_status(:success)
    end

    it "assigns @items" do
      get :index, params: { workspace_id: workspace.uuid, environment: environment.name }
      expect(assigns(:items)).to be_present
    end
  end

  # --- GET #show ---
  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: statefile.id }
      expect(response).to have_http_status(:success)
    end
  end

  # --- GET #edit ---
  describe "GET #edit" do
    it "returns http success and assigns @field" do
      get :edit, params: { id: statefile.id, field: "uuid" }
      expect(response).to have_http_status(:success)
      expect(assigns(:field)).to eq("uuid")
    end
  end

  # --- PATCH #update ---
  describe "PATCH #update" do
    context "with valid params" do
      it "redirects to statefile path with notice" do
        patch :update, params: { id: statefile.id, statefile: { uuid: statefile.uuid } }
        expect(response).to redirect_to(member_statefile_path(statefile, environment: environment.name))
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid params" do
      it "renders edit with unprocessable_entity" do
        allow_any_instance_of(Statefile).to receive(:update).and_return(false)
        patch :update, params: { id: statefile.id, statefile: { uuid: statefile.uuid } }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:edit)
      end
    end
  end

  # --- POST #duplicate ---
  describe "POST #duplicate" do
    it "creates a copy and redirects to workspace statefiles" do
      expect {
        post :duplicate, params: { id: statefile.id }
      }.to change(Statefile, :count).by(1)
      expect(response).to redirect_to(member_workspace_statefiles_path(workspace, environment: environment.name))
    end

    it "appends (n) suffix when a copy already exists" do
      expected_copy_uuid = "#{statefile.uuid} - Copy"
      existing_copy = statefile.dup
      existing_copy.uuid = expected_copy_uuid
      existing_copy.save!

      post :duplicate, params: { id: statefile.id }
      new_copy = Statefile.find_by(uuid: "#{expected_copy_uuid}(1)")
      expect(new_copy).to be_present
    end
  end

  # --- POST #push ---
  describe "POST #push" do
    it "updates published_at and redirects" do
      post :push, params: { id: statefile.id }
      expect(statefile.reload.published_at).to be_within(5.seconds).of(DateTime.now)
      expect(response).to redirect_to(member_workspace_statefiles_path(workspace, environment: environment.name))
    end
  end

  # --- DELETE #instance ---
  describe "DELETE #instance" do
    # resource index 2 = azurerm_subnet has 2 instances in sample4.1.tfstate
    let(:multi_instance_resource_index) { 2 }

    it "removes an instance and redirects to statefile" do
      content = JSON.parse(statefile.content)
      original_count = content["resources"][multi_instance_resource_index]["instances"].size

      delete :instance, params: { id: statefile.id, resource: multi_instance_resource_index, instance: 0 }

      expect(response).to redirect_to(member_statefile_path(statefile))
      updated = JSON.parse(statefile.reload.content)
      expect(updated["resources"][multi_instance_resource_index]["instances"].size).to eq(original_count - 1)
    end

    it "removes the resource when its last instance is deleted" do
      # resource index 0 = azurerm_resource_group has exactly 1 instance
      single_instance_index = 0
      content = JSON.parse(statefile.content)
      original_resource_count = content["resources"].size

      delete :instance, params: { id: statefile.id, resource: single_instance_index, instance: 0 }

      updated = JSON.parse(statefile.reload.content)
      expect(updated["resources"].size).to eq(original_resource_count - 1)
    end
  end
end
