class Member::DashboardController < Member::MemberController
  def index
    @days_range = Current.billing_range
    @chart_labels = @days_range.map { |date| I18n.l(date, format: "%d").capitalize }.to_json

    @chart_series_statefile = @days_range.map { |date| Current.account.usage_daily_accounts.where(service_name: 'Statefile').where(day: date).sum(:credits) }
    @chart_series_keyvalue = @days_range.map { |date| Current.account.usage_daily_accounts.where(service_name: 'KeyValueStore').where(day: date).sum(:credits) }

    @bar_graph_series = [
      { name: "Statefile", data: @chart_series_statefile },
      { name: "KeyValueStore", data: @chart_series_keyvalue }
    ]

    @usage = {
      keyvalue: Current.account.usage_daily_accounts.where(service_name: 'KeyValueStore').where(day: DateTime.now.at_beginning_of_month..DateTime.now.at_end_of_month).sum(:credits) || 0,
      statefile: Current.account.usage_daily_accounts.where(service_name: 'Statefile').where(day: DateTime.now.at_beginning_of_month..DateTime.now.at_end_of_month).sum(:credits) || 0,
      trustasset: Current.account.usage_daily_accounts.where(service_name: 'TrustAsset').where(day: DateTime.now.at_beginning_of_month..DateTime.now.at_end_of_month).maximum(:credits) || 0,
      license: Current.account.usage_daily_accounts.where(service_name: 'License').where(day: DateTime.now.at_beginning_of_month..DateTime.now.at_end_of_month).maximum(:credits) || 0
    }
    @usage[:total] = @usage[:keyvalue] + @usage[:statefile] + @usage[:trustasset] + @usage[:license]
  end
end