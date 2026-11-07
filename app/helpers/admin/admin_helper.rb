module Admin::AdminHelper
  def breadcrumbs
    [ controller_items[:"admin/dashboard"].merge(path: member_root_path) ]
  end
end
