class Member::AccountsController < Member::MemberController
  def new
    if Current.account&.id
      redirect_to (session[:redirect_to] || member_root_path), notice: "#{datum_name.capitalize} #{t('globals.created')}."
    else
      super()
    end
  end
    
  def create
    if controller_name == 'accounts'
      @item = datum.new(item_params)
      if @item.save
        create_result = @item.account_users.create(user: Current.user, role: Role.find_by(name: 'Owner'))
        if KeyHarbour.multi_org? == false
          Current.account.build_default_org_and_sub
        end
        if session[:coupon_id] && Coupon.where(id: session[:coupon_id]).count > 0
          item = Coupon.find(session[:coupon_id])
          if item.duration_limited
            subscription = @item.build_subscription(plan_id: session[:plan_id], current_period_start: DateTime.now, current_period_end: DateTime.now.advance(months: item.duration_in_month))
          else
            subscription = @item.build_subscription(plan_id: session[:plan_id], current_period_start: DateTime.now)
          end
          subscription.save
          subscription.subscription_coupons.create(coupon: item) if item
        end
        redirect_to (session[:redirect_to] || member_root_path), notice: "#{datum_name.capitalize} #{t('globals.created')}."
      else
        render :new, status: :unprocessable_entity
      end
    else
      super()
    end
  end

  def show
    redirect_to member_root_path, notice: "#{datum_name.capitalize} #{t('globals.created')}."
  end

  def datum
    Account
  end

  def datum_name
    t('activerecord.models.account')
  end
  
  def back_path
    return member_account_path(@item) if @item && !@item.new_record? && action_name.to_sym != :index
    member_accounts_path
  end

  private
  def set_breadcrumbs
    @breadcrumbs ||= []
  end

  def set_items
  end

  def item_params
    params.expect(account: [ :name, :address1, :address2, :zip, :country_code, :province_code, :billing_contact ])
  end

  # def set_item
  #   if controller_name == 'organizations'
  #     @item = datum.find_by!(uuid: params[:id])
  #     @organization = @item
  #   else
  #     super()
  #   end
  # end
end