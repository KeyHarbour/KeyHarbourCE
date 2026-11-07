require 'rails_helper'

# Controller anonyme pour exposer les comportements d'ApplicationController
class TestApplicationController < ApplicationController
  skip_before_action :set_items
  skip_before_action :set_organization
  skip_before_action :set_parent_obj
  skip_before_action :set_parent_item
  skip_before_action :set_breadcrumbs
  skip_before_action :log_history

  def index
    render plain: "ok"
  end

  def show
    render plain: "ok"
  end

  def new
    @item = OpenStruct.new
    render plain: "ok"
  end

  def create
    render plain: "ok"
  end

  def update
    render plain: "ok"
  end

  def destroy
    render plain: "ok"
  end
end

RSpec.describe ApplicationController, type: :controller do
  controller(TestApplicationController) do
  end

  let(:owner_role) { Role.find_or_create_by!(name: "Owner") }

  let(:account) do
    Account.unscoped.create!(
      name: "Test Account",
      country_code: "CA",
      province_code: "QC",
      billing_contact: "billing@test.com"
    )
  end

  let(:user) { create(:user) }

  let(:account_user) do
    AccountUser.unscoped.create!(user: user, account: account, role: owner_role)
  end

  let(:session_record) { Session.create!(user: user) }

  before do
    account_user
    Current.session = session_record
    cookies.signed[:session_id] = session_record.id
    allow(controller).to receive(:enforce_custom_permissions!).and_return(true)
    allow(Rails.configuration).to receive(:permission_service).and_return(double("ps", get: false))
  end

  # --- require_authentication ---
  describe "require_authentication" do
    context "without a valid session cookie" do
      before { Current.session = nil }

      it "redirects to login" do
        cookies.delete(:session_id)
        get :index
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "with a valid session cookie" do
      it "does not redirect" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  # --- check_password_change ---
  describe "#check_password_change" do
    context "when password change is required" do
      before { allow(user).to receive(:password_change_required?).and_return(true) }

      it "allows access to users#edit" do
        allow(controller).to receive(:controller_name).and_return("users")
        allow(controller).to receive(:action_name).and_return("edit")
        get :index
        expect(response).not_to redirect_to(edit_user_path(user))
      end

      it "allows access to users#update" do
        allow(controller).to receive(:controller_name).and_return("users")
        allow(controller).to receive(:action_name).and_return("update")
        get :index
        expect(response).not_to redirect_to(edit_user_path(user))
      end

      it "allows logout (sessions#destroy)" do
        allow(controller).to receive(:controller_name).and_return("sessions")
        allow(controller).to receive(:action_name).and_return("destroy")
        get :index
        expect(response).not_to redirect_to(edit_user_path(user))
      end
    end

    context "when password change is not required" do
      before { allow(user).to receive(:password_change_required?).and_return(false) }

      it "does not redirect" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  # --- set_locale ---
  describe "#set_locale" do
    it "uses locale from params when provided" do
      get :index, params: { locale: "fr" }
      expect(I18n.locale).to eq(:fr)
    end

    it "uses user preferred language when no param" do
      allow(user).to receive(:prefered_language).and_return("en")
      get :index
      expect(I18n.locale).to eq(:en)
    end

    it "falls back to default locale when no user" do
      Current.session = nil
      cookies.delete(:session_id)
      allow(controller).to receive(:require_authentication).and_return(true)
      allow(Current).to receive(:user).and_return(nil)
      get :index
      expect(I18n.locale).to eq(I18n.default_locale)
    end
  end

  # --- enforce_custom_permissions! ---
  describe "#enforce_custom_permissions!" do
    before { allow(controller).to receive(:enforce_custom_permissions!).and_call_original }

    context "when permission is granted" do
      before do
        guard = instance_double(UserPermissionService, allowed?: true)
        allow(UserPermissionService).to receive(:new).and_return(guard)
      end

      it "does not redirect" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context "when permission is denied" do
      before do
        guard = instance_double(UserPermissionService, allowed?: false)
        allow(UserPermissionService).to receive(:new).and_return(guard)
      end

      it "redirects to 403 page" do
        get :index
        expect(response).to redirect_to(errors_feature403_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  # --- except_organization_controller? ---
  describe "#except_organization_controller?" do
    it "returns false for a non-organization controller" do
      expect(controller.except_organization_controller?).to eq(false)
    end
  end

  # --- set_breadcrumb_actions ---
  describe "#set_breadcrumb_actions" do
    before { controller.instance_variable_set(:@breadcrumbs, []) }

    it "appends 'new' breadcrumb for new action" do
      allow(controller).to receive(:action_name).and_return("new")
      controller.send(:set_breadcrumb_actions)
      expect(controller.instance_variable_get(:@breadcrumbs).map { |b| b[:name] }).to include(I18n.t("globals.new"))
    end

    it "appends 'update' breadcrumb for edit action" do
      allow(controller).to receive(:action_name).and_return("edit")
      controller.send(:set_breadcrumb_actions)
      expect(controller.instance_variable_get(:@breadcrumbs).map { |b| b[:name] }).to include(I18n.t("globals.update"))
    end

    it "appends nothing for index action" do
      allow(controller).to receive(:action_name).and_return("index")
      controller.send(:set_breadcrumb_actions)
      expect(controller.instance_variable_get(:@breadcrumbs)).to be_empty
    end
  end
end
