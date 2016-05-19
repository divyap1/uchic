class CommissionsController < ApplicationController
  include CommissionsHelper

  before_action :set_commission, only: [:show, :edit, :update, :destroy]

  # GET /commissions
  # GET /commissions.json
  def index
    @commissions = Commission.publicly_visible
    @commissions = @commissions.contains(params[:search]) if params[:search].present?
    @commissions = Kaminari.paginate_array(@commissions).page(params[:page]).per(params[:display_size])
    @users = User.all
    @users = @users.contains(params[:search]) if params[:search].present?
  end

  # GET /commissions/1
  # GET /commissions/1.json
  def show
    @commission = Commission.find(params[:id])

    if @commission.buyer
      if @commission.related_to?(current_user)
        return redirect_to private_commission_url(@commission)
      else
        flash[:alert] = "Sorry, you don't have permission to view that commission."
        return redirect_to categories_url
      end
    end

    @category = Category.find(@commission.category_id)
    @seller = @commission.seller
    @ancestry = @category.ancestors << @category
    @section = @commission.name

    @similar_items = @category.commissions.order("RANDOM()").limit(3)

    @new_commission = Commission.new
  end

  # GET /commissions/new
  def new
    unless user_signed_in?
       flash.now[:alert] = "Guests can not sell items"
    end

    @categories = Category.all
    @commission = Commission.new
  end

  # GET /commissions/1/edit
  def edit

    @categories = Category.all

    #Can only edit commissions you added
    unless user_signed_in? && @commission.seller_id === current_user.id
      flash.now[:alert] = "You do not have the permissions to edit this listing."
    end

  end

  # POST /commissions
  # POST /commissions.json
  def create
    if params[:message_thread_id]
      @message_thread = MessageThread.find(params[:message_thread_id])
      @commission = @message_thread.commission = Commission.new(commission_params)
      @commission.buyer = @message_thread.buyer
    else
      @commission = Commission.new(commission_params)
    end

    respond_to do |format|
      if @commission.save
        pictures = [*params[:commission][:pictures]] || []
        pictures.each do |picture|
          @commission.pictures.create!(picture: picture)
        end

        @commission.accept!(current_user)

        if @message_thread
          @message_thread.save!
          MessageBroadcastController.publish('/commissions', commission_data(@commission))
        end

        if @commission.public
          @commission.seller.followers.each do |follower|
            notification = follower.notifications.new(about_user: current_user, state: "product listed", commission: @commission)
            notification.save!
          end
        end

        format.html { redirect_to @commission, notice: 'Commission was successfully added.' }
        format.json { render :show, status: :created, location: @commission }
      else
        format.html { render :new }
        format.json { render json: @commission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /commissions/1
  # PATCH/PUT /commissions/1.json
  def update
    respond_to do |format|
      if @commission.update(commission_params)
        if @commission.message_thread
          MessageBroadcastController.publish('/commissions', commission_data(@commission))
        end

        pictures = [*params[:commission][:pictures]] || []
        unless pictures.empty?
          @commission.pictures.destroy_all

          pictures.each do |picture|
            @commission.pictures.create!(picture: picture)
          end
        end

        @commission.accept!(current_user)

        format.html { redirect_to @commission, notice: 'Commission was successfully updated.' }
        format.json { render :show, status: :ok, location: @commission }
      else
        format.html { render :edit }
        format.json { render json: @commission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /commissions/1
  # DELETE /commissions/1.json
  def destroy
    #Check the current user posted the commission
    if user_signed_in? && (@commission.seller == current_user || @commission.buyer == current_user)
      @commission.destroy!
      if @commission.buyer
        @commission.buyer.notifications.create(about_user: current_user, commission: @commission, state: "request denied")
      end
      respond_to do |format|
        format.html { redirect_to user_dashboard_url, notice: 'Commission was successfully destroyed.'}
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to user_dashboard_url, alert: 'You do not have permissions to delete this item.' }
        format.json { head :no_content }
      end
    end
  end

  def make_copy
    @commission = Commission.find(params[:commission_id])
    @copy = Commission.new(:name => @commission.name,
                           :description => @commission.description,
                           :price => @commission.price,
                           :seller_id => params[:seller_id],
                           :buyer_id => params[:buyer_id],
                           :state => 'discussion',
                           :category_id => @commission.category_id,
                           :pictures => @commission.pictures,
                           :public => false)
    if @copy.save
      @copy.seller.notifications.create(about_user: @copy.buyer, state: "copy requested", commission: @copy)
      pictures = @copy.pictures
      pictures.each do |picture|
        @copy.pictures.create!(picture: picture.picture)
      end

      respond_to do |format|
        format.html { redirect_to @commission, notice: 'Your request was successfully sent.' }
        format.json { render :show, status: :created, location: @commission }
      end
    else
      respond_to do |format|
        format.html { redirect_to @commission, alert: 'There was an error sending your request. Please try again.' }
        format.json { render json: @commission.errors, status: :unprocessable_entity }
      end
    end
  end

  def make_similar
    @commission = Commission.find(params[:commission_id])
    desc = @commission.description + "Additional Details: " + params[:custom_info]


    @copy = Commission.new(:name => @commission.name,
                           :description => desc,
                           :price => @commission.price,
                           :seller_id => params[:seller_id],
                           :buyer_id => params[:buyer_id],
                           :state => 'discussion',
                           :category_id => @commission.category_id,
                           :pictures => @commission.pictures,
                           :public => false)
    if @copy.save
        @copy.seller.notifications.create(about_user: @copy.buyer, state: "similar requested", commission: @copy)

      pictures = @copy.pictures
      pictures.each do |picture|
        @copy.pictures.create!(picture: picture.picture)
      end

      respond_to do |format|
        format.html { redirect_to @commission, notice: 'Your request was successfully sent.' }
        format.json { render :show, status: :created, location: @commission }
      end
    else
      respond_to do |format|
        format.html { redirect_to @commission, alert: 'There was an error sending your request. Please try again.' }
        format.json { render json: @commission.errors, status: :unprocessable_entity }
      end
    end
  end

  def approve
    @commission = Commission.find(params[:id])
    @commission.accept!(current_user)
    @commission.buyer.notifications.create(about_user: current_user, commission: @commission, state: "request accepted");
    redirect_to @commission
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commission
      @commission = Commission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def commission_params
      params.require(:commission).permit(:name, :description, :price, :quantity, :seller_id, :picture, :category_id, :public)
    end
end
