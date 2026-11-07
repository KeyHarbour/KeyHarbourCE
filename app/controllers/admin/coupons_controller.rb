class Admin::CouponsController < Admin::AdminController
  def datum
    Coupon.order(id: :desc)
  end

  def datum_name
    t('activerecord.models.coupon')
  end
  
  def back_path
    admin_coupons_path
  end

  def activate
    set_items
    Coupon.where(id: @item.id).update_all(status: "active")
    @item.create_coupon
    redirect_to back_path, status: :see_other, notice: "#{datum_name.capitalize} #{t('globals.destroyed')}."
  end
  def desactivate
    set_items
    Coupon.where(id: @item.id).update_all(status: "disabled")
    @item.create_coupon
    redirect_to back_path, status: :see_other, notice: "#{datum_name.capitalize} #{t('globals.destroyed')}."
  end

  def destroy
    Coupon.where(id: @item.id).update_all(status: "disabled")
    Coupon.where(id: @item.id).update_all(stripe_id: nil)
    # @item.instance_variable_set(:@readonly, false)
    # @item.update_column(:status, "disabled")
    @item.delete_coupon
    redirect_to back_path, status: :see_other, notice: "#{datum_name.capitalize} #{t('globals.destroyed')}."
  end

  private
  def set_breadcrumbs
    @breadcrumbs ||= []
  end

  def set_items
    @item = datum.find_by(id: params[:id]) if params[:id]
  end

  def item_params
    params.expect(coupon: [ :name, :valid_at, :valid_until, :uuid, :amount_off, :percent_off, :duration_limited, :duration_in_month, :redeem_limit, :active, :plan_id ])
  end
end