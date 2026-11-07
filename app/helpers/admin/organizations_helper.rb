module Admin::OrganizationsHelper
  def new_item_url
    nil
  end

  def display_back
    true
  end

  def back_path
    admin_accounts_path
  end

  def index_page_name
    "Organizations"
  end

  def new_page_name
    "New organization"
  end

  def edit_page_name
    "Edit existing organization"
  end

  def form_url
    return admin_organizations_path(locale: I18n.locale) if @item.new_record?
    admin_organization_path(@item, locale: I18n.locale)
  end

  def top_buttons
    return [] unless action_name == "index"
    [
      {
        name: "Accounts",
        link: back_path,
        icon: "ki-filled ki-arrow-left"
      }
    ]
  end
end
