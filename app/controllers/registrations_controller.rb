class RegistrationsController < Devise::RegistrationsController
  def show
    @user = current_user
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :address, :email,:username, :password, :password_confirmation, :profile_picture, :country,
    :card_name, :card_number, :expiration_month, :expiration_year, :security_code)
  end

  def account_update_params
    params.require(:user).permit(:name, :address, :email, :username, :password, :password_confirmation, :current_password, :profile_picture,
    :country, :card_name, :card_number, :expiration_month, :expiration_year, :security_code)
  end
end
