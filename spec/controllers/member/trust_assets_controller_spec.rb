require "rails_helper"

RSpec.describe Member::TrustAssetsController, type: :controller do
  include_context "member_auth"

  let(:workspace)   { workspaces(:infra_nexus) }
  let(:environment) { environments(:sandbox_kh) }
  let(:trust_asset) { trust_assets(:tas_app_fivetran_ssl_reminder) }
  let(:datum_scope) { workspace.trust_assets.where(environment: environment) }

  before do
    allow(KeyHarbour).to receive(:trust_assets?).and_return(true)
    allow(controller).to receive(:trust_assets?).and_return(true)
    allow(controller).to receive(:set_items).and_wrap_original do |_m|
      controller.instance_variable_set(:@workspace, workspace)
      controller.instance_variable_set(:@environment, environment)
      controller.instance_variable_set(:@item, trust_asset)
      controller.instance_variable_set(:@project, workspace.project)
      controller.instance_variable_set(:@organization, workspace.project.organization)
    end
    allow(controller).to receive(:datum).and_return(datum_scope)
    allow_any_instance_of(TrustAsset).to receive(:update_expiry)
    allow_any_instance_of(Workspace).to receive(:fix_cost)
  end

  # --- GET #index ---
  describe "GET #index" do
    before { allow(datum_scope).to receive(:search).and_return(datum_scope) }

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
      get :show, params: { id: trust_asset.id }
      expect(response).to have_http_status(:success)
    end
  end

  # --- GET #new ---
  describe "GET #new" do
    it "returns http success" do
      get :new, params: { workspace_id: workspace.uuid, environment: environment.name }
      expect(response).to have_http_status(:success)
    end
  end

  # --- GET #edit ---
  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: trust_asset.id }
      expect(response).to have_http_status(:success)
    end
  end

  # --- POST #create ---
  describe "POST #create" do
    let(:valid_params) do
      {
        workspace_id: workspace.uuid,
        environment: environment.name,
        trust_asset: {
          name: "New SSL Cert",
          issuer: "Let's Encrypt",
          format: "tls_certificate",
          consumer: "nginx",
          expires_at: 90.days.from_now.to_fs(:db),
          environment_id: environment.id,
          reminder_days: 30
        }
      }
    end

    context "with valid params" do
      it "creates a trust asset and redirects to back_path" do
        expect {
          post :create, params: valid_params
        }.to change(TrustAsset, :count).by(1)
        expect(response).to redirect_to(member_workspace_trust_assets_path(workspace, environment: environment.name))
        expect(flash[:notice]).to be_present
      end

      it "calls update_expiry before saving" do
        expect_any_instance_of(TrustAsset).to receive(:update_expiry)
        post :create, params: valid_params
      end
    end

    context "with invalid params" do
      it "renders new with unprocessable_entity" do
        allow_any_instance_of(TrustAsset).to receive(:save).and_return(false)
        post :create, params: valid_params
        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:new)
      end
    end
  end

  # --- PATCH #update ---
  describe "PATCH #update" do
    let(:update_params) do
      {
        id: trust_asset.id,
        trust_asset: {
          name: "Updated Cert",
          issuer: trust_asset.issuer,
          format: trust_asset.format,
          consumer: trust_asset.consumer,
          expires_at: trust_asset.expires_at.to_fs(:db),
          environment_id: environment.id
        }
      }
    end

    context "with valid params" do
      it "updates and redirects to back_path with notice" do
        patch :update, params: update_params
        expect(response).to redirect_to(member_workspace_trust_assets_path(workspace, environment: environment.name))
        expect(flash[:notice]).to be_present
      end

      it "calls update_expiry after update" do
        expect_any_instance_of(TrustAsset).to receive(:update_expiry)
        patch :update, params: update_params
      end
    end

    context "with invalid params" do
      it "renders edit with unprocessable_entity" do
        allow_any_instance_of(TrustAsset).to receive(:update).and_return(false)
        patch :update, params: update_params
        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template(:edit)
      end
    end
  end

  # --- DELETE #destroy ---
  describe "DELETE #destroy" do
    it "destroys the trust asset and redirects" do
      expect {
        delete :destroy, params: { id: trust_asset.id }
      }.to change(TrustAsset, :count).by(-1)
    end
  end
end
