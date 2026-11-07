class Member::UsersController < Member::MemberController
  before_action :validate_admin?
  def index
    @item = datum.build(item_params)
    @query = @item.name || '*'

    search_options = {
      hitsPerPage: 20,
      attributesToHighlight: [ 'name' ]
    }

    @pagy, @items = pagy(datum.search(@query, search_options), limit: 10)
  end
  
  def new
    @item = datum.new
    @item.build_account_user 
  end

  def create
    @item = datum.new(item_params)
    @item.password_change_required = true
    @item.password =  SecureRandom.base64(18)
    @item.account_user.account_id = Current.account.id
    @item.account_user.role_id = item_params[:account_user_attributes][:role_id]
    if @item.save  
      redirect_to member_user_path(@item), notice: "#{datum_name.capitalize} #{t('globals.created')}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def datum
    Current.account.users
  end

  def datum_name
    t('activerecord.models.user')
  end

  def edit
    @user = Current.user
  end
  
  def back_path
    member_users_path()
  end

  # def update
  #   @user = Current.user
  #   if @user.update(item_params)
  #     redirect_to @user, notice: "Profile updated successfully."
  #   else
  #     render :edit
  #   end
  # end

  def show
    @user = User.find(params[:id])
  end

  private
    def item_params
      return {} unless params[:user].present?

      params.expect(user: [ :email_address, 
        account_user_attributes: [ :id, :role_id, :account_id ] ])
    end

    def set_item
      @item = datum.find_by!(id: params[:id])
      @user = @item
    end

  # def user_params
  #   params.require(:user).permit(:email_address, :password, :password_confirmation, :prefered_language)
  # end
end
