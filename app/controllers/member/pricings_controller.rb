class Member::PricingsController < Member::MemberController
  before_action :validate_admin?
  def index
    @coupon_subscription = Current.subscription.subscription_coupons.new
  end
end