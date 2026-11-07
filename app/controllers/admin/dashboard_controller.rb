class Admin::DashboardController < Admin::AdminController
  def index
    @total = {
      statefile_size: 0,
      keyvalue_size: 0
    }
    if ProcessedDate.all.count == 0
      ProcessedDate.create(day: DateTime.current.advance(days: -30))
    end
  end
end