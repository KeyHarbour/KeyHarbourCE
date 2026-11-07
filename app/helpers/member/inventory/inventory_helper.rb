module Member::Inventory::InventoryHelper
  def breadcrumbs
    super
  end

  def th(name, size)
    content_tag :th, class: "#{ size.nil? ? '' : "w-#{size}"}" do
      content_tag :span, class: "kt-table-col" do
        content_tag :span, class: "kt-table-col-label" do
          name
        end
      end
    end
  end
end