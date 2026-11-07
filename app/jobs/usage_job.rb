class UsageJob < ApplicationJob
  queue_as :default

  def perform(*args)
    CreditUsageService.new.process
    UsageService.call
  end
end
