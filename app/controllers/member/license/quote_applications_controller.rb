class Member::License::QuoteApplicationsController < ActionController::Base
  def update
    @quote_application = License::QuoteApplication.find_by(id: params[:id])
    if @quote_application.update(item_params)
      redirect_to member_license_quote_path(@quote_application.quote, locale: I18n.locale, field: params[:field]), notice: "Champ mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit
    @quote_application = License::QuoteApplication.find_by(id: params[:id])
  end

  def show
    if params[:field].present?
      render partial: "quote_field", locals: { quote: @quote, field: params[:field] }
    end
  end

  private

    def item_params
      return {} unless params[:license_quote_application].present?
      params.expect(license_quote_application: [ :amount, :seats ])
    end  
end