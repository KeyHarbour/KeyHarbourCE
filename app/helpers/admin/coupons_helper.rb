module Admin::CouponsHelper
  def display_back
    true
  end

  def new_item_url
    new_admin_coupon_path()
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
