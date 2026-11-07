class RegisteringJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.configuration.register.save_license
  end
end
