class UsersController < ApplicationController
  before_filter :authenticate_user!, only: [:dashboard, :activity_feed]

  def profile
    @user = User.find(params[:id])
    @review = Review.new
    @reviews = @user.reviews

    @num_reviews = @reviews.nil? ? 0 : @reviews.length
    @average_review = @num_reviews == 0  ? 0 : @reviews.map(&:rating).inject(0, &:+) / @num_reviews
  end

  def activity_feed
    @user = current_user
    @notifications = @user.notifications.order(created_at: :desc)
    byebug
  end

  def listings
  	@commissions = Commission.where(seller_id: current_user.id)
  end

  def my_commissions
    @commissions = Commission.where(buyer_id: current_user.id)
  end

  def private_commission
    @commission = Commission.find(params[:id])
    @seller = @commission.seller
  end

  def edit_private_commission
  end

  def dashboard
    @user = current_user
    if user_signed_in?
      @commissions = Commission.where(seller_id: current_user.id)
      @req_commissions = Commission.where(buyer_id: current_user.id)
    end
  end
end
