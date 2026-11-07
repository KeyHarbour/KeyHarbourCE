class Admin::UsersController < Admin::AdminController
  def edit
    @user = User.find(params[:id])
    logger.debug "User's account_user before build: #{@user.account_user.inspect}".yellow
    @user.build_account_user if @user.account_user.nil?
    logger.debug "User's account_user before build: #{@user.account_user.inspect}".yellow
  end

  def update
    if @item.update(item_params)
      if !@item.account
        @item.account = Current.user.account
        @item.save
      end
      @item.index!
      redirect_to back_path, notice: "#{datum_name.capitalize} #{t('globals.updated')}."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def index
    @item = datum.new(item_params)

    query = params[:user]&.[](:email_address).presence || "*"
    logger.debug "Search query: #{query}".green

    filter = []
    filter << "account_name = '#{@item.account_name}' " unless @item.account_name.blank?
    # filter << "issuer = '#{@item.issuer}' " unless @item.issuer.blank?
    # filter << "consumer = '#{@item.consumer}' " unless @item.consumer.blank?
    # filter << "format = '#{@item.format}' " unless @item.format.blank?


    logger.debug filter
    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ],
      filter: filter.join(" AND ")
    }
    @pagy, @items = pagy(datum.search(query, search_options), limit: 10)
  end

  def show
    @user = User.find(params[:id])
  end
  
  def back_path
    admin_accounts_path
  end

  def datum
    return @account.users.all.order(:email_address) if @account
    # return User.where.missing(:account_user) unless params[:id]
    User
  end

  private
  def set_parent_obj
    @account = Account.find(params[:account_id]) if params[:account_id]
  end

  def datum_name
    "user"
  end
  
  def back_path
    admin_users_path(@account)
  end

  def item_params
    unless params[:user].present?
      return {}
    end
    params.require(:user).permit(:email_address, :global_role, :password, :password_confirmation, :prefered_language, :account_name, account_user_attributes: [ :role_id, :account_id, :id ])
  end
end
