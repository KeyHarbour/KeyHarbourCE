class Member::SubscriptionCouponsController < Member::MemberController
  def create
    @item = Coupon.actifs.find_by(uuid: params[:subscription_coupon][:coupon_code])

    if @item.nil?
      Notification.create!(
        recipient: Current.user,
        message: "Le code que vous avez saisie est inactif, inexistant ou deja utilisé. Veuillez vérifier et réessayer.",
        title: "Merci"
      )
      redirect_to member_root_path and return
    end


    Current.subscription.subscription_coupons.create(coupon: @item)
    Notification.create!(
      recipient: Current.user,
      message: "Le code saisie est valide, il sera appliqué sur la prochaine période.",
      title: "Merci"
    )
    redirect_to member_pricings_path
  end
end