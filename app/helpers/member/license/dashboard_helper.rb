module Member::License::DashboardHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/license/dashboard", member_license_root_path, @item&.name, @item&.id )
    result
  end

  def bg_color(usage_rate)
    if usage_rate < 0.7
      "bg-info-lt"
    elsif usage_rate < 0.9
      "bg-success-lt"
    elsif usage_rate < 1
      "bg-warning-lt"
    else
      "bg-danger-lt"
    end
  end
end
