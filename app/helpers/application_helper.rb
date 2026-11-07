module ApplicationHelper
  include Pagy::Method
  include PagyBootstrapHelper

  def new_name(item)
    I18n.t("globals.new") + " " + t("activerecord.models.#{item.class.name.underscore.gsub('/', "_")}")
  end

  def page_title
    item = breadcrumbs.last
    capture do
      concat icon(item[:icon]) if item[:icon].present?    
      concat ' '
      prefix = ''
      prefix = new_name(@item) if action_name == 'new'
      # logger.debug item    
      prefix = "Edit " + t("activerecord.models.#{@item.class.name.underscore.gsub('/', "_")}") if action_name == 'edit'
      full_title = [ prefix, item[:page_title] || item[:title] ].compact.join(' ')
  
      # logger.debug full_title
      concat full_title
    end
  end

  def renewal_color(item)
    return 'bg-red kh_white' if item.renewal_level == 0
    return 'bg-yellow kh_white' if  item.renewal_level == 1
    return 'bg-primary kh_white' if  item.renewal_level == 2
    'bg-green kh_white'
  end

  def expires_color(item)
    return 'bg-red kh_white' if item.expires_at < DateTime.now
    return 'bg-yellow kh_white' if item.expires_at.advance(days: -item.reminder_days) <= DateTime.now
    'bg-green kh_white'
  end

  CONTROLLERS = {
    "admin/dashboard": { title: I18n.t('member.member_controller.global_dashboard'), icon: 'dashboard' },
    "admin/accounts": { title: I18n.t('member.member_controller.accounts_management'), icon: 'users-group' },
    "admin/users": { title: I18n.t('member.member_controller.all_users'), icon: 'users' },
    "admin/coupons": { title: I18n.t('activerecord.models.coupon').pluralize, icon: 'briefcase' },
    "member/accounts": { title: (Current.account&.name || I18n.t('activerecord.models.account')), icon: 'home' },
    "member/dashboard": { title: (Current.account&.name || I18n.t('activerecord.models.account')), icon: 'home' },
    # "member/applications": { title: I18n.t('menu.account_applications'), icon: 'apps' },
    "member/organizations": { title: I18n.t('menu.all_organizations'), icon: 'binary-tree-2', exclude_controllers: %w[member/license/team_members member/license/applications member/inventory/instances member/inventory/model_families member/inventory/model_categories member/inventory/model_category_attrs member/workspaces member/tokens member/trust_assets member/statefiles member/key_value_stores] },
    "member/teams": { title: I18n.t('menu.teams'), icon: 'users-group' },
    "member/users": { title: I18n.t('menu.users'), icon: 'users' },
    "member/subscriptions": { title: I18n.t('activerecord.models.subscription'), icon: 'plug-connected' },
    "member/pricings": { title: I18n.t('menu.pricings'), icon: 'home-dollar' },
    "member/inventory/instances": { title: I18n.t('menu.inventory_instances'), icon: 'box', variables: %w[organization], exclude_controllers: %w[member/workspaces member/tokens member/trust_assets member/statefiles member/key_value_stores] },
    "member/inventory/model_families": { title: I18n.t('menu.inventory_model_families'), icon: 'box', variables: %w[organization] },
    "member/inventory/model_categories": { title: I18n.t('menu.inventory_model_categories'), icon: 'box', variables: %w[organization] },
    "member/inventory/model_category_attrs": { title: I18n.t('menu.inventory_model_category_attrs'), icon: 'box', variables: %w[organization] },
    "member/projects": { title: I18n.t('menu.projects'), icon: 'anchor' },
    "member/licenses": { title: I18n.t('menu.licenses'), icon: 'license' },
    "member/trust_assets": { title: I18n.t('menu.trust_assets'), icon: 'kh-certificat', variables: %w[organization project workspace] },
    "member/statefiles": { title: I18n.t('menu.statefiles'), icon: 'kh-terraform', variables: %w[organization project workspace] },
    "member/statefile_tags": { title: I18n.t('menu.statefile_tags'), icon: 'kh-terraform', variables: %w[organization project workspace] },
    "member/key_value_stores": { title: I18n.t('menu.key_value_stores'), icon: 'kh-keyvalue', variables: %w[organization project workspace] },
    "member/license/dashboard": { title: I18n.t("menu.licenses_dashboard"), icon: 'dashboard' },
    "member/license/applications": { title: I18n.t("menu.applications"), icon: 'kh-application', sub_controllers: %w[member/license/quotes member/license/licensees] },
    "member/license/instances": { title: I18n.t("menu.instances", name: @application&.name), icon: 'browser' },
    "member/license/quotes": { title: I18n.t("menu.quotes"), icon: 'receipt-dollar', variables: %w[application] },
    "member/license/add_ons": { title: I18n.t("menu.add_ons"), icon: 'package' },
    "member/license/team_members": { title: I18n.t("menu.team_members"), icon: 'hierarchy-3' },
    "member/license/providers": { title: I18n.t("menu.providers"), icon: 'octahedron' },
    "member/license/licensees": { title: I18n.t("menu.licensees"), icon: 'hierarchy-3' },
    "member/api_queries": { title: I18n.t('menu.api_queries'), icon: 'api-app' },
    "member/environments": { title: I18n.t('menu.environments'), icon: 'stack-2', variables: %w[organization] },
    "member/org_tokens": { title: I18n.t('menu.tokens'), icon: 'key', variables: %w[organization] },
    "member/tokens": { title: I18n.t('menu.tokens'), icon: 'key', variables: %w[organization project] },
    "member/workspaces": { title: I18n.t('menu.workspaces'), icon: 'virtual-space', variables: %w[organization project workspace] },
    "member/wizard/statefiles/statefiles": { title: "Statefiles Wizard", icon: 'virtual-space' },
    "member/wizard/key_values/key_values": { title: "KeyValue Wizard", icon: 'virtual-space' },
    "member/wizard/trust_assets/trust_assets": { title: "TrustAssets Wizard", icon: 'virtual-space' }
  }

  def controller_items
    ApplicationHelper::CONTROLLERS
  end

  def status_color(item)
    return "bg-green" if item.active?
    return "bg-yellow" if item.disabled?
    "bg-red"
  end

  def current_route_helper_name
    route_details = Rails.application.routes.recognize_path(request.path)
    route = Rails.application.routes.routes.find do |r|
      r.defaults[:controller] == route_details[:controller] && r.defaults[:action] == route_details[:action]
    end
    route ? "#{route.name}" : nil
  end

  def search
    false
  end

  def step_back
    false
  end

  def breadcrumbs_restfull(my_controller_path, index_path, show_title, id)
    result = []
    result << controller_items[my_controller_path].merge(path: index_path)
    if controller_path.to_sym == my_controller_path and %w[new edit show destroy].include? action_name
      title = action_name
      title = show_title if [ "show", "edit", "new" ].include?(action_name)
      result << controller_items[my_controller_path].merge(path: url_for(controller: my_controller_path, action: action_name, id: id), title: title)
    elsif controller_path.to_sym != my_controller_path
      result << controller_items[my_controller_path].merge(path: url_for(controller: "/#{my_controller_path}", action: "show", id: id), title: show_title)
    end
    result
  end

  def controller_from_path(path)
    return nil if path.blank?
    clean_path = URI.parse(path).path
    route_params = Rails.application.routes.recognize_path(clean_path)
    controller_name = route_params[:controller]
    permission_controller = "permissions/#{controller_name}".classify
    permission_controller += 's' if controller_name.split('/').last != "dashboard"
    permission_controller_class = permission_controller.constantize
    permission_controller_instance = permission_controller_class.new(Current.user, route_params[:action], @organization || nil )
    show_this = permission_controller_instance.send("#{route_params[:action]}?")
    return nil if show_this == false
    route_params[:controller].to_sym
  rescue ActionController::RoutingError
    nil
  end

  def set_active_for_item_for(parent_variable, controller, controller_path)
    if parent_variable and !(controller_items[controller.to_sym].dig(:exclude_controllers) || []).include?(controller_path)
      (controller_items[controller_path.to_sym].dig(:variables) || []).each do |variable|
        if instance_variable_defined?("@#{variable}")
          return true if instance_variable_get("@#{variable}") == parent_variable
        end
      end
    end
    nil
  end

  def item_for(route, start_with: true, restfull: false, parent_variable: nil, debug: false)
    # logger.debug "Route: #{route}"
    controller = controller_from_path(route)
    return nil if controller.nil?
    paths = []
    if restfull != false
      # logger.debug "Rrestfull: #{restfull} - #{!(restfull[:except] || []).include?(action_name)}"
      active = (controller == controller_path.to_sym) && !(restfull[:except] || []).include?(action_name)
    else
      paths = [ route ]
      active = start_with == true ? request.path.start_with?(route) : paths.include?(request.path)
      active = false if (controller_items[controller].dig(:exclude_controllers) || []).include?(controller_path)
      active = set_active_for_item_for(parent_variable, controller, controller_path) || active
    end
    if (controller_items[controller].dig(:sub_controllers) || []).include? controller_path
      active = true
    end
    if debug == true
      logger.debug controller_items.to_yaml
      logger.debug "Controller: #{controller}"
      logger.debug controller_items[controller][:title]
      logger.debug "Exclude path: #{controller_items[controller][:exclude_controllers]}"
      logger.debug "Request Path: #{request.path}"
      logger.debug "Route: #{route}".red
      logger.debug "Controller Path: #{controller_path}"
      logger.debug "Controller Items: #{controller_items[controller_path.to_sym]}"
      logger.debug "StartWith: #{start_with}"
      logger.debug "Paths: #{paths}"
      logger.debug "PathInclude: #{paths.include?(request.path)}"
      logger.debug "active: #{active}"
      logger.debug "------".red
    end
    # logger.debug "active: #{active}".red
    {
      title: controller_items[controller][:title],
      icon: controller_items[controller][:icon],
      controllers: [ controller ],
      path: route,
      active: active
    }
  end

  def nav_items_for_admin
    return nil unless Current.user.global_role.to_sym == :admin

    items = []
    items << item_for(admin_root_path, start_with: false)
    items << item_for(admin_accounts_path)
    items << item_for(admin_coupons_path)
    items << item_for(admin_users_path)
    items = items.compact
    active = items.any? { |hash| hash[:active] == true }
    item_for(admin_root_path).except(:path).merge(items: items, active: active)
  end

  def nav_items_for_member
    items = []
    items << item_for(member_root_path, start_with: false).merge(title: I18n.t('menu.dashboard'))
    items << item_for(member_organizations_path, start_with: false, restfull: { except: %w[show] }, debug: false)
    items << item_for(member_teams_path)
    items << item_for(member_users_path)
    items << item_for(member_subscriptions_path, debug: false)
    items << item_for(member_pricings_path)
    items = items.compact
    active = items.any? { |hash| hash[:active] == true }
    item_for(member_root_path).except(:path).merge(items: items, active: active, title: truncate((Current.account&.name || I18n.t('activerecord.models.account')), length: 20))
  end

  def nav_items_for_licence
    return nil unless KeyHarbour.license?

    items = []
    items << item_for(member_license_root_path)
    items << item_for(member_license_applications_path)
    items << item_for(member_license_providers_path)
    items << item_for(member_license_team_members_path)    
    active = items.any? { |hash| hash[:active] == true }
    item_for(member_license_applications_path).except(:path).merge(items: items, active: active)
  end

  def nav_items_for_organizations
    items = []
    active = false
    Current.organizations.each do |organization|
      next unless organization.id
      sub_items = []
      sub_items << item_for(member_organization_path(organization), parent_variable: organization, start_with: true, debug: false).merge(title: I18n.t('menu.organization_overview'), icon: "eye")

      # sub_sub_items = []
      

      # active = sub_sub_items.any? { |hash| hash[:active] == true }
      # sub_items << item_for(member_organization_license_applications_path(organization)).except(:path).merge(title: I18n.t('menu.licenses'), items: sub_sub_items, active: active)

      sub_items << item_for(member_organization_inventory_instances_path(organization), parent_variable: organization, debug: false).merge(title: I18n.t('menu.organization_inventory'))
      organization.projects.not_archived.current_user(Current).limit(10).each do |project|
        sub_items << item_for(Current.user.project_view(project) ? member_project_path(project) : member_project_workspaces_path(project), parent_variable: project).merge(title: project.name)
      end
      active = sub_items.any? { |hash| hash[:active] == true }

      items << item_for(member_organization_path(organization)).except(:path).merge(title: organization.name, items: sub_items, active: active)
    end
    items
  end

  def nav_menu_simple
    [
      nav_items_for_admin,
      nav_items_for_member,
      nav_items_for_licence
    ].compact + nav_items_for_organizations
  end

  def display_back
    false
  end

  def add_button(position); end

  def add_list_button
    []
  end

  def langs
    {
      en: { name: "English", flag: "united-states" },
      fr: { name: "Français", flag: "france" }
    }
  end

  def index_page_name
    datum_name
  end

  def new_page_name
    I18n.t('globals.new_with', name: datum_name)
  end

  def edit_page_name
    I18n.t('globals.edit_with', name: datum_name)
  end

  def role_badge(role)
    case role
    when 'admin'
      content_tag :span, class: "kt-badge kt-badge-primary kt-badge-outline rounded-[30px]" do
        I18n.t('member.member_controller.admin')
      end
    when 'default'
      content_tag :span, class: "kt-badge kt-badge-success kt-badge-outline rounded-[30px]" do
        I18n.t('member.member_controller.member')
      end
    when 'desactivated'
      content_tag :span, class: "kt-badge kt-badge-destructive kt-badge-outline rounded-[30px]" do
        I18n.t('member.member_controller.desactivated')
      end
    else
      content_tag :span, class: "kt-badge kt-badge-secondary kt-badge-outline rounded-[30px]" do
        role.capitalize
      end
    end
  end

  def pagy_first_last(pagy)
    html = pagy_nav(pagy)
    first = ''
    last = ''

    first = link_to("<<", pagy_url_for(pagy, 1), class: "page-link first") if pagy.page > 1
    last = link_to(">>", pagy_url_for(pagy, pagy.last), class: "page-link last") if pagy.page < pagy.last
    html = html.gsub('aria-label="Pages">', 'aria-label="Pages">'.html_safe + first)
    html = html.gsub('</nav>', last + "</nav>".html_safe)
    # logger.debug html
    html.html_safe
  end

  def back_path
  end

  def new_item
  end

  def th(name, size, align = "left")
    content_tag :th, class: "w-[#{size}px] text-#{align}" do
      content_tag :span, class: "kt-table-col" do
        content_tag :span, class: "kt-table-col-label" do
          name
        end
      end
    end
  end

  def license(organization)
    items = {
      name: I18n.t('menu.licenses'),
      # link: member_organization_license_applications_path(organization),
      icon: "ki-filled ki-tab-tablet",
      items: [
          {
            link: member_organization_license_applications_path(organization),
            name: t("menu.organization_applications"),
            icon: "ki-filled ki-screen",
            active: [ "member/license/applications", "member/license/instances", "member/license/licensees" ].include?(controller_path) && @organization.present? && @organization == organization
          },
          {
            link: member_organization_license_team_members_path(organization),
            name: t("menu.organization_team_members"),
            icon: "ki-filled ki-data",
            active: @organization.present? && controller_name == "team_members"
          }
        ]
    }
    items[:items].each do |sub_item|
      if sub_item[:active] == true
        items[:active] = true
      end
    end
    items
  end

  def form_url
    @item
  end

  def top_buttons
    nil
  end

  def level1_active?(item)
    return "here show" if item[:active] == true
    ''
  end

  def menu_item_sub_items?(item)
    result = {}
    result = { "data-kt-menu-item-toggle": "accordion", "data-kt-menu-item-trigger": "click" } if item[:items].present?
    result[:class] = show_menu_item?(item)
    result[:class] += ' active' if request.path == item[:link]
    result
  end

  def sub_menu_active?(item)
    if item.include?(:active)
      return 'active' if item[:active] == true
      return ''
    end
    return '' if item[:no_match] && item[:no_match].include?([ controller_name.to_sym, action_name.to_sym ])
    return '' if item[:no_controllers] && item[:no_controllers].include?(controller_name)
    return 'active' if request.path == item[:link]
    return 'active' if request.path.start_with?(item[:link]) unless item[:start_with].present? || item[:start_with] == false
    return 'active' if request.path.start_with?(item[:start_with]) if item.include?(:start_with)
    ''
  end

  def show_menu_item?(item)
    return 'show' if item.dig(:active) == true
    return 'show' if item.include?(:start_with) && request.path.start_with?(item[:start_with]) 
    return 'show' if item[:controllers] && item[:controllers].include?(controller_name)
    unless item[:items].blank?
      item[:items].each do |sub_item|
        return 'show' if request.path == sub_item[:link]
      end
    end
    ''
  end
  
  def province_options(country_code)
    # On cherche le pays via son code ISO (ex: "CA", "FR")
    country = Carmen::Country.coded(country_code)
    
    if country
      # On récupère les subdivisions (provinces/états)
      country.subregions.map { |s| [ s.name, s.code ] }
    else
      []
    end
  end

  def flash_class(type)
    case type.to_sym
    when :notice then "bg-green-600 border-green-700"
    when :alert, :error then "bg-red-600 border-red-700"
    else "bg-blue-600 border-blue-700"
    end
  end  

  def bg_color(level)
    case level.to_i
    when 0
      "bg-red-100"
    when 1
      "bg-orange-100"
    when 2
      "bg-blue-100"
    else
      "bg-green-100"
    end
  end
end
