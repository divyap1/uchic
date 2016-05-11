class UsersController < ApplicationController
  before_filter :authenticate_user!, only: [:dashboard]

  def profile
    @user = User.find(params[:id])
    @reviews = @user.reviews

    @num_reviews = @reviews.nil? ? 0 : @reviews.length
    @average_review = @num_reviews == 0  ? 0 : @reviews.map(&:rating).inject(0, &:+) / @num_reviews

    #@user.reviews.create(reviewer: current_user, user: @user, rating: 1, comment: "cool")
  end

  def listings
  	@products = Product.where(seller_id: current_user.id)
  end

  def dashboard
    @user = current_user
    if user_signed_in?
      @orders = Order.where(buyer_id: current_user.id)
      @products = Product.where(seller_id: current_user.id)
    end
  end
end
