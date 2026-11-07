module Member::SubscriptionsHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/subscriptions", member_subscriptions_path, @item&.name, @item&.id )
    result
  end

  def progress_color(usage_rate)
    if usage_rate > 0.95
      "kt-progress-destructive"
    elsif usage_rate > 0.75
      "kt-progress-warning"
    else
      "kt-progress-primary"
    end
  end
end