class UsersController < ApplicationController
  skip_before_action :enforce_custom_permissions!
  
  def datum_name
    "user"
  end
  
  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    @user.password_change_required = false
    if @user.update(user_params)
      redirect_to edit_user_path(@user), notice: t('controllers.users.profile_updated')
    else
      render :edit
    end
  end

  private

  private
    def item_params
      params.expect(user: [ :email_address ])
    end

    def set_item
      @item = Current.user
    end

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :prefered_language)
  end
end
