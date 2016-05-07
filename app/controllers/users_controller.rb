class UsersController < ApplicationController
  before_filter :authenticate_user!, only: [:dashboard]

  def profile
    @user = User.find(params[:id])
  end

  def dashboard
    @user = current_user
  end
end
