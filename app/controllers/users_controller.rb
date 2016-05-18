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
  end

  def listings
  	@commissions = Commission.where(seller_id: current_user.id)
  end

  def my_commissions
    @commissions = Commission.where(buyer_id: current_user.id)
  end

  def private_commission
    @commission = Commission.find(params[:id])
  end

  def pay
    @commission = Commission.find(params[:id])
  end

  def pay_now
    @commission = Commission.find(params[:commission_id])
    @user = User.find(params[:buyer_id])

    if @user.address && @user.card_name && @user.card_number && @user.expiration_year && @user.expiration_month && @user.security_code
      @commission.update!(:state => 'paid')

      respond_to do |format|
        format.html { redirect_to @commission, notice: 'Your payment was successfully processed'}
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, alert: 'Your payment could not be processed. Make sure that you
           have provided a shipping address and your payment details'}
        format.json { head :no_content }
      end
    end
  end

  def edit_shipping

  end

  def edit_payment
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
