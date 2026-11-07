class Member::SubscriptionsController < Member::MemberController
  before_action :validate_admin?
  skip_before_action :enforce_custom_permissions!, only: [ :success, :fail ]
  # skip_before_action :verify_authenticity_token, only: [:webhook]
  # skip_before_action :require_authentication, only: [:webhook], raise: false

  def index
    @subscription = Current.subscription
  end

  def success
    checkout_session_id = params['session_id']
    checkout_session = Plan.client.v1.checkout.sessions.retrieve(checkout_session_id)
    subscription = Plan.client.v1.subscriptions.retrieve(checkout_session.subscription)
    subscription_data = subscription.items.data
    if Current.subscription.invoices.where(stripe_invoice_id: checkout_session.invoice).empty?
      Current.subscription.update(
        plan_id: params[:plan], 
        stripe_customer_id: checkout_session.customer, 
        current_period_start: Time.at(subscription_data.first.current_period_start), 
        current_period_end: Time.at(subscription_data.first.current_period_end),
        yearly: params[:period] == "year"
      )
      Current.subscription.subscription_credits.add(Current.subscription.plan.credits, :initial)
      invoice = Current.subscription.invoices.create!(
        stripe_invoice_id: checkout_session.invoice,
        amount: checkout_session.amount_total / 100.0,
        status: 'paid',
        period_start: Time.at(subscription_data.first.current_period_start),
        date: Time.at(checkout_session.created),
        ref: "F-#{Current.account.uuid}-#{sprintf('%04d', Current.subscription.invoices.count + 1)}".upcase,
        period_end: Time.at(subscription_data.first.current_period_end)
      )
    end

    Notification.create!(
      recipient: Current.user,
      message: t("member.subscriptions.success.body"),
      title: t("member.subscriptions.success.title")
    )
    render :index, locals: { new_invoice: true }
  end

  def fail
    Notification.create!(
      recipient: Current.user,
      message: t("member.subscriptions.fail.body"),
      title: t("member.subscriptions.fail.title")
    )
    render :index, locals: { cancelled: true }
  end

  def create
    if params[:plan].to_s == 'free'
      Current.subscription.set_stripe_customer_id
      redirect_to member_root_path
      return
    end
    plan = Plan.find(params[:plan])
    price_id = plan.price_id!(params[:period])

    data = {
      mode: 'subscription',
      line_items: [ {
        quantity: 1,
        price: price_id
      } ],
      success_url: root_url + "/member/subscriptions/#{Current.subscription.id}/success?session_id={CHECKOUT_SESSION_ID}&plan=#{plan.id}&period=#{params[:period]}",
      cancel_url: root_url + "/member/subscriptions/#{Current.subscription.id}/fail?session_id={CHECKOUT_SESSION_ID}&plan=#{plan.id}&period=#{params[:period]}"
    }
    if Current.subscription.subscription_coupons.where(used: nil).count > 0
      subscription_coupons = Current.subscription.subscription_coupons.where(used: nil).first
      data[:discounts] = [ {
        coupon: subscription_coupons.coupon.stripe_id
      } ]
      subscription_coupons.update!(used: DateTime.now)
    end
    session = Plan.client.v1.checkout.sessions.create(data)
    logger.debug session.url
    if session.url.start_with?("https://checkout.stripe.com")
      redirect_to session.url, allow_other_host: true
    else
      redirect_to member_root_url, alert: "Une erreur de sécurité est survenue lors de la redirection vers le paiement."
    end
  end

  def set_item; end
end