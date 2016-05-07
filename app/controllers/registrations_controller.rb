class RegistrationsController < Devise::RegistrationsController
  def show
    @user = current_user
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :address, :email, :password, :password_confirmation, :profile_picture)
  end

  def account_update_params
    params.require(:user).permit(:name, :address, :email, :password, :password_confirmation, :current_password, :profile_picture)
  end
end
