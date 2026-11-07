class Member::License::QuoteAddOnsController < ActionController::Base
  def update
    @quote_add_on = License::QuoteAddOn.find_by(id: params[:id])
    if @quote_add_on.update(item_params)
      redirect_to member_license_quote_path(@quote_add_on.quote_instance.quote_application.quote, locale: I18n.locale, field: params[:field]), notice: "Champ mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit
    @quote_add_on = License::QuoteAddOn.find_by(id: params[:id])
  end

  def show
    if params[:field].present?
      render partial: "quote_field", locals: { quote: @quote, field: params[:field] }
    end
  end

  def deactivate
    @item = License::QuoteAddOn.find_by(id: params[:id])
    @item.update(unused: true)
    redirect_to member_license_quote_path(@item.quote_instance.quote_application.quote, locale: I18n.locale), notice: "Add-on deactivated."
  end

  def activate
    @item = License::QuoteAddOn.find_by(id: params[:id])
    @item.update(unused: false)
    redirect_to member_license_quote_path(@item.quote_instance.quote_application.quote, locale: I18n.locale), notice: "Add-on activated."
  end

  private

    def item_params
      return {} unless params[:license_quote_add_on].present?
      params.expect(license_quote_add_on: [ :amount, :seats ])
    end  
end