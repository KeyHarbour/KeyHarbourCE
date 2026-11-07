class SslCheckerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    TrustAsset.all.each do |trust_asset|
      trust_asset.update_expiry
      trust_asset.save
    end
  end
end
