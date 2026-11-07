class TrustAssetsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Account.all.each do |account|
      logger.debug "Checking trust assets for account #{account.name} (#{account.id})"
      next unless account.trust_assets.any?

      logger.info "Sending trust asset reminders for account #{account.name} (#{account.id})"
      account.account_users.where(role: Role.find_by(name: 'Owner')).each do |account_user|
        logger.debug "Sending to user #{account_user.user.email_address}"
        logger.debug "----".red * 50
        TrustAssetMailer.with(user: account_user.user, account: account).reminders.deliver_later
      end
    end
  end
end
