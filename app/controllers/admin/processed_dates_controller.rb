class Admin::ProcessedDatesController < Admin::AdminController
  def destroy
    processed_date = ProcessedDate.find_by(id: params[:id])
    flash_message = "#{processed_date.day} #{t('globals.destroyed')}."
    processed_date.destroy
    UsageDailyAccount.where(day: processed_date.day).destroy_all
    UsageDailyOrganization.where(day: processed_date.day).destroy_all
    UsageDailyProject.where(day: processed_date.day).destroy_all
    UsageDailyWorkspace.where(day: processed_date.day).destroy_all
    credit_usage_service = CreditUsageService.new(processed_date.day.advance(days: -1))
    credit_usage_service.usage_monthly_account
    redirect_to admin_root_path, status: :see_other, alert: flash_message
  end
end