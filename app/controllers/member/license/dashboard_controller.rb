class Member::License::DashboardController < Member::License::LicenseController
  def index
    @applications = Current.applications.sort_by(&:usage_rate).reverse
    @pie_chart = { 0 => 0, 1 => 0, 2 => 0, 3 => 0 }
    treemap_chart = { 0 => 0, 1 => 0, 2 => 0, 3 => 0 }
    # { "Over-consuming" => 0, "Over licensed" => 0, "License threshold" => 0, "Optimal consumption" => 0 }
    Current.applications.events(DateTime.current.advance(years: -3), DateTime.current.advance(years: 3)).each do |event|
      @pie_chart[event[:item].renewal_level] += 1
      treemap_chart[event[:item].usage_rate_level] += 1
    end
    @pie_chart_values = @pie_chart.values
    @pie_chart_labels = [ t('.overdue'), t('.last_reminder'), t('.first_reminder'), t('.no_reminder') ]
    @pie_chart_values = @pie_chart.values

    @treemap_data = [ 
      { 
        name: 'Licenses', data: [ 
          { x: "#{t('.over_licensed')} (#{treemap_chart[0]})", y: treemap_chart[0] }, 
          { x: "#{t('.optimal_consumption')} (#{treemap_chart[1]})", y: treemap_chart[1] }, 
          { x: "#{t('.license_threshold')} (#{treemap_chart[2]})", y: treemap_chart[2] }, 
          { x: "#{t('.over_consuming')} (#{treemap_chart[3]})", y: treemap_chart[3] } 
        ] 
      } 
    ]
  end
end

