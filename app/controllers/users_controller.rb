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
    @seller = User.find(@commission.seller_id)
    @seller = User.find(@commission.buyer_id)
  end

  def pay
    @commission = Commission.find(params[:id])
  end

  def pay_now
    @commission = Commission.find(params[:commission_id])

    min_num = 0
    name = params[:name].length > min_num
    address = params[:address].length > min_num
    card_name = params[:card_name].length > min_num
    card_number = params[:card_number].length >= 12
    expiration_year = params[:year].length > min_num
    expiration_month = params[:month].length > min_num
    security_code = params[:code].length > min_num

    if name && address && card_name && card_number && expiration_year && expiration_month && security_code
      @commission.update!(:state => 'in_progress')

      respond_to do |format|
        format.html { redirect_to private_commission_path(@commission.id), notice: 'Your payment was successfully processed'}
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, alert: 'Your payment could not be processed. Make sure that you
           have provided a shipping address and your payment details are valid.'}
        format.json { head :no_content }
      end
    end
  end

  def edit_private_commission
  end

  def dashboard
    @user = current_user
    if user_signed_in?
      # get most recently opened commissions by seller
      @commissions = Commission.where(seller_id: current_user.id).last(8)

      # only show most recent commissions that are currently active
      @req_commissions = Commission.where(buyer_id: current_user.id, state:
                          ['discussion', 'accepted', 'in_progress', 'shipped']).last(8)

    end
  end
end
