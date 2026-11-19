require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  # --- new_name ---
  describe "#new_name" do
    it "returns the translated new model name" do
      item = double("item", class: double(name: "Member::Project"))
      allow(I18n).to receive(:t).with("globals.new").and_return("New")
      allow(helper).to receive(:t).with("activerecord.models.member_project").and_return("Project")

      expect(helper.new_name(item)).to eq("New Project")
    end
  end

  # --- page_title ---
  describe "#page_title" do
    before do
      helper.define_singleton_method(:icon) { |_name| "" }
      helper.define_singleton_method(:breadcrumbs) { [] }
      allow(helper).to receive(:icon).with("anchor").and_return("<i class='icon-anchor'></i>".html_safe)
    end

    it "renders title with icon for standard actions" do
      allow(helper).to receive(:breadcrumbs).and_return([ { icon: "anchor", title: "Projects" } ])
      allow(helper).to receive(:action_name).and_return("index")

      result = helper.page_title
      expect(result).to include("<i class='icon-anchor'></i>")
      expect(result).to include("Projects")
    end

    it "uses page_title over title if present" do
      allow(helper).to receive(:breadcrumbs).and_return([ { title: "Projects", page_title: "All Projects" } ])
      allow(helper).to receive(:action_name).and_return("index")

      expect(helper.page_title.strip).to eq("All Projects")
    end

    it "prefixes with new_name when action is new" do
      item = double("item", class: double(name: "Project"))
      helper.instance_variable_set(:@item, item)
      allow(helper).to receive(:breadcrumbs).and_return([ { title: "Project" } ])
      allow(helper).to receive(:action_name).and_return("new")
      allow(helper).to receive(:new_name).with(item).and_return("New Project")

      expect(helper.page_title.strip).to eq("New Project Project")
    end

    it "prefixes with Edit when action is edit" do
      item = double("item", class: double(name: "Member::Project"))
      helper.instance_variable_set(:@item, item)
      allow(helper).to receive(:breadcrumbs).and_return([ { title: "My Project" } ])
      allow(helper).to receive(:action_name).and_return("edit")
      allow(helper).to receive(:t).with("activerecord.models.member_project").and_return("Project")

      expect(helper.page_title.strip).to eq("Edit Project My Project")
    end
  end

  # --- renewal_color ---
  describe "#renewal_color" do
    let(:item) { double("item") }

    it "returns red for level 0" do
      allow(item).to receive(:renewal_level).and_return(0)
      expect(helper.renewal_color(item)).to eq("bg-red kh_white")
    end

    it "returns yellow for level 1" do
      allow(item).to receive(:renewal_level).and_return(1)
      expect(helper.renewal_color(item)).to eq("bg-yellow kh_white")
    end

    it "returns primary for level 2" do
      allow(item).to receive(:renewal_level).and_return(2)
      expect(helper.renewal_color(item)).to eq("bg-primary kh_white")
    end

    it "returns green for level 3+" do
      allow(item).to receive(:renewal_level).and_return(3)
      expect(helper.renewal_color(item)).to eq("bg-green kh_white")
    end
  end

  # --- expires_color ---
  describe "#expires_color" do
    let(:item) { double("item", reminder_days: 15) }

    it "returns red when already expired" do
      allow(item).to receive(:expires_at).and_return(2.days.ago.to_datetime)
      expect(helper.expires_color(item)).to eq("bg-red kh_white")
    end

    it "returns yellow when within reminder days" do
      allow(item).to receive(:expires_at).and_return(10.days.from_now.to_datetime)
      expect(helper.expires_color(item)).to eq("bg-yellow kh_white")
    end

    it "returns green when expiration is far in the future" do
      allow(item).to receive(:expires_at).and_return(30.days.from_now.to_datetime)
      expect(helper.expires_color(item)).to eq("bg-green kh_white")
    end
  end

  # --- status_color ---
  describe "#status_color" do
    let(:item) { double("item") }

    it "returns green when active" do
      allow(item).to receive(:active?).and_return(true)
      allow(item).to receive(:disabled?).and_return(false)
      expect(helper.status_color(item)).to eq("bg-green")
    end

    it "returns yellow when disabled" do
      allow(item).to receive(:active?).and_return(false)
      allow(item).to receive(:disabled?).and_return(true)
      expect(helper.status_color(item)).to eq("bg-yellow")
    end

    it "returns red when archived" do
      allow(item).to receive(:active?).and_return(false)
      allow(item).to receive(:disabled?).and_return(false)
      expect(helper.status_color(item)).to eq("bg-red")
    end
  end

  # --- current_route_helper_name ---
  describe "#current_route_helper_name" do
    before do
      allow(helper).to receive(:request).and_return(double(path: "/member/teams"))
    end

    it "returns the matching route helper name" do
      route = double("route", name: "member_teams", defaults: { controller: "member/teams", action: "index" })
      allow(Rails.application.routes).to receive(:recognize_path).with("/member/teams").and_return({ controller: "member/teams", action: "index" })
      allow(Rails.application.routes).to receive(:routes).and_return([ route ])

      expect(helper.current_route_helper_name).to eq("member_teams")
    end

    it "returns nil when no route matches" do
      allow(Rails.application.routes).to receive(:recognize_path).with("/member/teams").and_return({ controller: "unknown", action: "index" })
      allow(Rails.application.routes).to receive(:routes).and_return([])

      expect(helper.current_route_helper_name).to be_nil
    end
  end

  # --- breadcrumbs_restfull ---
  describe "#breadcrumbs_restfull" do
    before do
      allow(helper).to receive(:url_for).and_return("/member/projects/1")
    end

    it "returns index and current action breadcrumb when on same controller" do
      allow(helper).to receive(:controller_path).and_return("member/projects")
      allow(helper).to receive(:action_name).and_return("show")

      result = helper.breadcrumbs_restfull(:"member/projects", "/member/projects", "Project Alpha", 1)
      expect(result.size).to eq(2)
      expect(result.first[:path]).to eq("/member/projects")
      expect(result.last[:title]).to eq("Project Alpha")
    end

    it "returns index only when on index action of same controller" do
      allow(helper).to receive(:controller_path).and_return("member/projects")
      allow(helper).to receive(:action_name).and_return("index")

      result = helper.breadcrumbs_restfull(:"member/projects", "/member/projects", "Project Alpha", 1)
      expect(result.size).to eq(1)
    end

    it "returns index and show breadcrumb when on a child controller" do
      allow(helper).to receive(:controller_path).and_return("member/workspaces")
      allow(helper).to receive(:action_name).and_return("index")

      result = helper.breadcrumbs_restfull(:"member/projects", "/member/projects", "Project Alpha", 1)
      expect(result.size).to eq(2)
      expect(result.last[:title]).to eq("Project Alpha")
    end
  end

  # --- controller_from_path ---
  describe "#controller_from_path" do
    let(:user) { double("user") }

    before do
      allow(Current).to receive(:user).and_return(user)
    end

    it "returns nil when path is blank" do
      expect(helper.controller_from_path("")).to be_nil
      expect(helper.controller_from_path(nil)).to be_nil
    end

    it "returns controller symbol when user has permission" do
      perm_instance = double("permission", index?: true)
      perm_class = double("PermissionClass", new: perm_instance)

      allow(Rails.application.routes).to receive(:recognize_path).with("/member/teams").and_return({ controller: "member/teams", action: "index" })
      stub_const("Permissions::Member::Teams", perm_class)

      expect(helper.controller_from_path("/member/teams")).to eq(:"member/teams")
    end

    it "handles dashboard controller naming without pluralizing" do
      perm_instance = double("permission", index?: true)
      perm_class = double("PermissionClass", new: perm_instance)

      allow(Rails.application.routes).to receive(:recognize_path).with("/admin").and_return({ controller: "admin/dashboard", action: "index" })
      stub_const("Permissions::Admin::Dashboard", perm_class)

      expect(helper.controller_from_path("/admin")).to eq(:"admin/dashboard")
    end

    it "returns nil when permission check returns false" do
      perm_instance = double("permission", index?: false)
      perm_class = double("PermissionClass", new: perm_instance)

      allow(Rails.application.routes).to receive(:recognize_path).with("/member/teams").and_return({ controller: "member/teams", action: "index" })
      stub_const("Permissions::Member::Teams", perm_class)

      expect(helper.controller_from_path("/member/teams")).to be_nil
    end

    it "rescues ActionController::RoutingError and returns nil" do
      allow(Rails.application.routes).to receive(:recognize_path).and_raise(ActionController::RoutingError.new("No route"))
      expect(helper.controller_from_path("/invalid/route")).to be_nil
    end
  end

  # --- set_active_for_item_for ---
  describe "#set_active_for_item_for" do
    let(:org) { double("organization") }

    it "returns true when parent_variable matches instance variable and controller is not excluded" do
      helper.instance_variable_set(:@organization, org)
      result = helper.set_active_for_item_for(org, :"member/environments", "member/environments")
      expect(result).to be true
    end

    it "returns nil when controller is in exclude_controllers" do
      helper.instance_variable_set(:@organization, org)
      result = helper.set_active_for_item_for(org, :"member/organizations", "member/workspaces")
      expect(result).to be_nil
    end
  end

  # --- item_for ---
  describe "#item_for" do
    before do
      allow(helper).to receive(:request).and_return(double(path: "/member/teams"))
      allow(helper).to receive(:controller_path).and_return("member/teams")
      allow(helper).to receive(:action_name).and_return("index")
    end

    it "returns nil if controller_from_path is nil" do
      allow(helper).to receive(:controller_from_path).with("/secret").and_return(nil)
      expect(helper.item_for("/secret")).to be_nil
    end

    it "returns formatted nav hash when active" do
      allow(helper).to receive(:controller_from_path).with("/member/teams").and_return(:"member/teams")
      result = helper.item_for("/member/teams")

      expect(result).to include(
        icon: "users-group",
        controllers: [ :"member/teams" ],
        path: "/member/teams",
        active: true
      )
    end

    it "handles restfull option with except" do
      allow(helper).to receive(:controller_from_path).with("/member/organizations").and_return(:"member/organizations")
      allow(helper).to receive(:controller_path).and_return("member/organizations")
      allow(helper).to receive(:action_name).and_return("show")

      result = helper.item_for("/member/organizations", restfull: { except: %w[show] })
      expect(result[:active]).to be false
    end

    it "activates parent when current controller is in sub_controllers" do
      allow(helper).to receive(:controller_from_path).with("/member/license/applications").and_return(:"member/license/applications")
      allow(helper).to receive(:controller_path).and_return("member/license/quotes")

      result = helper.item_for("/member/license/applications")
      expect(result[:active]).to be true
    end

    it "executes debug logging without error when debug: true" do
      allow(helper).to receive(:controller_from_path).with("/member/teams").and_return(:"member/teams")
      allow_any_instance_of(String).to receive(:red) { |str| str }

      expect { helper.item_for("/member/teams", debug: true) }.not_to raise_error
    end
  end

  # --- Navigation builders ---
  describe "Navigation menu builders" do
    let(:user) { double("user", global_role: "admin") }
    let(:account) { double("account", name: "Acme Corporation Ltd") }

    before do
      allow(Current).to receive(:user).and_return(user)
      allow(Current).to receive(:account).and_return(account)
      allow(Current).to receive(:organizations).and_return([])

      allow(helper).to receive(:admin_root_path).and_return("/admin")
      allow(helper).to receive(:admin_accounts_path).and_return("/admin/accounts")
      allow(helper).to receive(:admin_coupons_path).and_return("/admin/coupons")
      allow(helper).to receive(:admin_users_path).and_return("/admin/users")
      allow(helper).to receive(:member_root_path).and_return("/member")
      allow(helper).to receive(:member_organizations_path).and_return("/member/organizations")
      allow(helper).to receive(:member_teams_path).and_return("/member/teams")
      allow(helper).to receive(:member_users_path).and_return("/member/users")
      allow(helper).to receive(:member_subscriptions_path).and_return("/member/subscriptions")
      allow(helper).to receive(:member_pricings_path).and_return("/member/pricings")
      allow(helper).to receive(:member_license_root_path).and_return("/member/license")
      allow(helper).to receive(:member_license_applications_path).and_return("/member/license/applications")
      allow(helper).to receive(:member_license_providers_path).and_return("/member/license/providers")
      allow(helper).to receive(:member_license_team_members_path).and_return("/member/license/team_members")

      allow(helper).to receive(:item_for) do |path, **_opts|
        { title: "Title #{path}", icon: "icon", path: path, active: path == "/member/teams" }
      end
    end

    describe "#nav_items_for_admin" do
      it "returns admin menu items for admin users" do
        result = helper.nav_items_for_admin
        expect(result[:items].size).to eq(4)
        expect(result[:active]).to be false
      end

      it "returns nil for non-admin users" do
        allow(user).to receive(:global_role).and_return("member")
        expect(helper.nav_items_for_admin).to be_nil
      end
    end

    describe "#nav_items_for_member" do
      it "returns member menu with truncated account name" do
        result = helper.nav_items_for_member
        expect(result[:items].size).to eq(6)
        expect(result[:active]).to be true
        expect(result[:title].length).to be <= 20
      end
    end

    describe "#nav_items_for_licence" do
      it "returns license menu when KeyHarbour.license? is true" do
        allow(KeyHarbour).to receive(:license?).and_return(true)
        result = helper.nav_items_for_licence
        expect(result[:items].size).to eq(4)
      end

      it "returns nil when KeyHarbour.license? is false" do
        allow(KeyHarbour).to receive(:license?).and_return(false)
        expect(helper.nav_items_for_licence).to be_nil
      end
    end

    describe "#nav_items_for_organizations" do
      it "builds organization sub-items including active projects" do
        project = double("project", name: "Proj 1")
        projects_scope = double("projects_scope", not_archived: double(current_user: double(limit: [ project ])))
        org = double("organization", id: 1, name: "Org One", projects: projects_scope)

        allow(Current).to receive(:organizations).and_return([ org ])
        allow(user).to receive(:project_view).with(project).and_return(true)
        allow(helper).to receive(:member_organization_path).with(org).and_return("/member/orgs/1")
        allow(helper).to receive(:member_organization_inventory_instances_path).with(org).and_return("/member/orgs/1/inv")
        allow(helper).to receive(:member_project_path).with(project).and_return("/member/projects/1")

        result = helper.nav_items_for_organizations
        expect(result.size).to eq(1)
        expect(result.first[:title]).to eq("Org One")
        expect(result.first[:items].size).to eq(3)
      end
    end

    describe "#nav_menu_simple" do
      it "combines admin, member, license and organization menus" do
        allow(KeyHarbour).to receive(:license?).and_return(false)
        result = helper.nav_menu_simple
        expect(result.size).to eq(2)
      end
    end
  end

  # --- Page name & override helpers ---
  describe "Page name & override helpers" do
    before do
      helper.define_singleton_method(:datum_name) { "Workspaces" }
    end

    it "returns index, new and edit page names" do
      allow(I18n).to receive(:t).with("globals.new_with", name: "Workspaces").and_return("New Workspaces")
      allow(I18n).to receive(:t).with("globals.edit_with", name: "Workspaces").and_return("Edit Workspaces")

      expect(helper.index_page_name).to eq("Workspaces")
      expect(helper.new_page_name).to eq("New Workspaces")
      expect(helper.edit_page_name).to eq("Edit Workspaces")
    end

    it "returns expected defaults for override methods" do
      expect(helper.search).to eq(false)
      expect(helper.step_back).to eq(false)
      expect(helper.display_back).to eq(false)
      expect(helper.add_button(:top)).to be_nil
      expect(helper.add_list_button).to eq([])
      expect(helper.back_path).to be_nil
      expect(helper.new_item).to be_nil
      expect(helper.top_buttons).to be_nil
    end

    it "returns @item for form_url" do
      item = double("item")
      helper.instance_variable_set(:@item, item)
      expect(helper.form_url).to eq(item)
    end
  end

  # --- role_badge ---
  describe "#role_badge" do
    it "renders primary badge for admin" do
      expect(helper.role_badge("admin")).to include("kt-badge-primary")
    end

    it "renders success badge for default" do
      expect(helper.role_badge("default")).to include("kt-badge-success")
    end

    it "renders destructive badge for desactivated" do
      expect(helper.role_badge("desactivated")).to include("kt-badge-destructive")
    end

    it "renders secondary capitalized badge for other roles" do
      html = helper.role_badge("viewer")
      expect(html).to include("kt-badge-secondary")
      expect(html).to include("Viewer")
    end
  end

  # --- pagy_first_last ---
  describe "#pagy_first_last" do
    before do
      helper.define_singleton_method(:pagy_nav) { |_pagy| "" }
      helper.define_singleton_method(:pagy_url_for) { |_pagy, _page| "" }
    end

    it "adds first and last page links when on a middle page" do
      pagy = double("pagy", page: 2, last: 5)
      allow(helper).to receive(:pagy_nav).with(pagy).and_return('<nav aria-label="Pages"><span>2</span></nav>')
      allow(helper).to receive(:pagy_url_for).with(pagy, 1).and_return("/items?page=1")
      allow(helper).to receive(:pagy_url_for).with(pagy, 5).and_return("/items?page=5")

      result = helper.pagy_first_last(pagy)
      expect(result).to include('href="/items?page=1"')
      expect(result).to include('href="/items?page=5"')
    end
  end

  # --- th & license ---
  describe "#th" do
    it "renders a table header cell with width and alignment" do
      html = helper.th("Email", 150, "right")
      expect(html).to include("w-[150px] text-right")
      expect(html).to include("Email")
    end
  end

  describe "#license" do
    let(:org) { double("organization") }

    before do
      helper.instance_variable_set(:@organization, org)
      allow(helper).to receive(:member_organization_license_applications_path).with(org).and_return("/orgs/1/apps")
      allow(helper).to receive(:member_organization_license_team_members_path).with(org).and_return("/orgs/1/members")
    end

    it "marks parent active when on applications controller" do
      allow(helper).to receive(:controller_path).and_return("member/license/applications")
      allow(helper).to receive(:controller_name).and_return("applications")

      result = helper.license(org)
      expect(result[:active]).to be true
      expect(result[:items].first[:active]).to be true
    end

    it "marks parent active when on team_members controller" do
      allow(helper).to receive(:controller_path).and_return("member/license/team_members")
      allow(helper).to receive(:controller_name).and_return("team_members")

      result = helper.license(org)
      expect(result[:active]).to be true
      expect(result[:items].last[:active]).to be true
    end
  end

  # --- menu_item_sub_items? ---
  describe "#menu_item_sub_items?" do
    before do
      allow(helper).to receive(:request).and_return(double(path: "/member/teams"))
      allow(helper).to receive(:controller_name).and_return("teams")
    end

    it "adds accordion attributes when sub-items are present and active class on path match" do
      item = { link: "/member/teams", items: [ { link: "/sub" } ], active: true }
      result = helper.menu_item_sub_items?(item)

      expect(result[:"data-kt-menu-item-toggle"]).to eq("accordion")
      expect(result[:class]).to include("show")
      expect(result[:class]).to include("active")
    end
  end

  # --- flash_class ---
  describe "#flash_class" do
    it "returns green for :notice" do
      expect(helper.flash_class(:notice)).to eq("bg-green-600 border-green-700")
    end

    it "returns red for :alert and :error" do
      expect(helper.flash_class(:alert)).to eq("bg-red-600 border-red-700")
      expect(helper.flash_class(:error)).to eq("bg-red-600 border-red-700")
    end

    it "returns blue for unknown type" do
      expect(helper.flash_class(:info)).to eq("bg-blue-600 border-blue-700")
    end
  end

  # --- bg_color ---
  describe "#bg_color" do
    it "returns expected background classes for levels 0 to 3+" do
      expect(helper.bg_color(0)).to eq("bg-red-100")
      expect(helper.bg_color(1)).to eq("bg-orange-100")
      expect(helper.bg_color(2)).to eq("bg-blue-100")
      expect(helper.bg_color(3)).to eq("bg-green-100")
      expect(helper.bg_color("0")).to eq("bg-red-100")
    end
  end

  # --- langs & province_options ---
  describe "#langs & #province_options" do
    it "returns en and fr entries with name and flag" do
      expect(helper.langs.keys).to contain_exactly(:en, :fr)
      helper.langs.each_value { |v| expect(v).to include(:name, :flag) }
    end

    it "returns provinces for valid country and empty array for invalid code" do
      expect(helper.province_options("CA")).not_to be_empty
      expect(helper.province_options("ZZ")).to eq([])
    end
  end

  # --- level1_active?, show_menu_item?, sub_menu_active?, controller_items ---
  describe "Menu visibility & controller_items helpers" do
    before do
      allow(helper).to receive(:request).and_return(double(path: "/member/organizations"))
      allow(helper).to receive(:controller_name).and_return("organizations")
      allow(helper).to receive(:action_name).and_return("index")
    end

    it "evaluates level1_active?" do
      expect(helper.level1_active?({ active: true })).to eq("here show")
      expect(helper.level1_active?({ active: false })).to eq("")
    end

    it "evaluates show_menu_item? across all conditions" do
      expect(helper.show_menu_item?({ active: true })).to eq("show")
      expect(helper.show_menu_item?({ start_with: "/member" })).to eq("show")
      expect(helper.show_menu_item?({ controllers: [ "organizations" ] })).to eq("show")
      expect(helper.show_menu_item?({ items: [ { link: "/member/organizations" } ] })).to eq("show")
      expect(helper.show_menu_item?({ items: [ { link: "/admin" } ] })).to eq("")
    end

    it "evaluates sub_menu_active? across all conditions" do
      expect(helper.sub_menu_active?({ active: true })).to eq("active")
      expect(helper.sub_menu_active?({ active: false })).to eq("")
      expect(helper.sub_menu_active?({ no_match: [ [ :organizations, :index ] ] })).to eq("")
      expect(helper.sub_menu_active?({ no_controllers: [ "organizations" ] })).to eq("")
      expect(helper.sub_menu_active?({ link: "/member/organizations" })).to eq("active")
      expect(helper.sub_menu_active?({ link: "/member", start_with: "/member" })).to eq("active")
      expect(helper.sub_menu_active?({ link: "/admin" })).to eq("")
    end

    it "returns CONTROLLERS hash" do
      expect(helper.controller_items).to eq(ApplicationHelper.controller_items)
    end
  end
end
