module Admin::CouponsHelper
  def display_back
    true
  end

  def new_item_url
    new_admin_coupon_path()
  end

  def add_button(position)
    controller_items[:'admin/coupons'].merge(path: new_item_url, title: new_name(@item)) if position == :top and action_name == 'index'
  end

  def index_page_name
    "CouponCode"
  end

  def edit_page_name
    "Edit existing organization"
  end

  def form_url
    return admin_coupons_path if @item.new_record?
    admin_coupon_path(@item)
  end

  def top_buttons
    []
  end
end
