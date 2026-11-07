class Member::License::QuoteInstancesController < ActionController::Base
  def update
    @quote_instance = License::QuoteInstance.find_by(id: params[:id])
    if @quote_instance.update(item_params)
      redirect_to member_license_quote_path(@quote_instance.quote_application.quote, locale: I18n.locale, field: params[:field]), notice: "Champ mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit
    @quote_instance = License::QuoteInstance.find_by(id: params[:id])
  end

  def show
    if params[:field].present?
      render partial: "quote_field", locals: { quote: @quote, field: params[:field] }
    end
  end

  def deactivate
    @item = License::QuoteInstance.find_by(id: params[:id])
    @item.update(unused: true)
    redirect_to member_license_quote_path(@item.quote_application.quote, locale: I18n.locale), notice: "Instance deactivated."
  end

  def activate
    @item = License::QuoteInstance.find_by(id: params[:id])
    @item.update(unused: false)
    redirect_to member_license_quote_path(@item.quote_application.quote, locale: I18n.locale), notice: "Instance activated."
  end

  private

    def item_params
      return {} unless params[:license_quote_instance].present?
      params.expect(license_quote_instance: [ :amount, :seats ])
    end  
end