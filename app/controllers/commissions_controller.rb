class CommissionsController < ApplicationController
  include CommissionsHelper

  before_action :set_commission, only: [:show, :edit, :update, :destroy]

  # GET /commissions
  # GET /commissions.json
  def index
    @page_title = params[:search].present? ? params[:search] : "All content"

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

    seller_country_code = ISO3166::Country.find_country_by_name(@commission.seller.country_name).currency.code
    user_country = current_user.country_name if user_signed_in?
    user_country ||= "New Zealand"
    user_country_code = ISO3166::Country.find_country_by_name(user_country).currency.code

    @price = Money.new(@commission.price * 100, seller_country_code).exchange_to(user_country_code)
    @price = Money.new(@price, user_country_code).format

    @page_title = @commission.name

    if @commission.private? && @commission.buyer
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

    @similar_items = @category.commissions.select{|commission| commission.public && commission!=@commission}
    @similar_items = @similar_items.sample(3)


    @new_commission = Commission.new
  end

  # GET /commissions/new
  def new
    unless user_signed_in?
       flash.now[:alert] = "Guests can not sell items"
    end

    @page_title = "List commission"
    @message_thread = MessageThread.find(params[:message_thread_id]) if params[:message_thread_id]

    @categories = Category.all
    @commission = Commission.new
  end

  # GET /commissions/1/edit
  def edit
    @page_title = @commission.name
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
      @commission = @message_thread.commission = Commission.new(commission_params.merge(public: false))
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
        @page_title = "List commission"

        format.html { render :new }
        format.json { render json: @commission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /commissions/1
  # PATCH/PUT /commissions/1.json
  def update
    @page_title = @commission.name

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

        if @commission.buyer
          @commission.unaccept!(@commission.partner(current_user))
          @commission.accept!(current_user)

          @commission.seller.notifications.find_by(commission: @commission).destroy if @commission.seller.notifications.find_by(commission: @commission)
          @commission.buyer.notifications.find_by(commission: @commission).destroy if @commission.buyer.notifications.find_by(commission: @commission)
          @commission.buyer.notifications.create(about_user: @commission.seller, state: "counter offer", commission: @commission)
        end

        format.html { redirect_to @commission, notice: 'Commission was successfully updated' }
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
      @commission.update_attributes!(active: false)
      if @commission.buyer
        @commission.buyer.notifications.create(about_user: current_user, commission: @commission, state: "request denied")
        Notification.find_by(commission: @commission).destroy
        respond_to do |format|
          format.html { redirect_to (params[:return_to] || user_dashboard_url), notice: 'Commission was successfully declined'}
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to user_dashboard_url, notice: 'Commission was successfully deleted'}
          format.json { head :no_content }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, alert: 'You do not have permissions to delete this item.' }
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
                           :pictures => @commission.pictures.dup,
                           :accepted_by_buyer => true,
                           :public => false)

    if @copy.save
      @copy.seller.notifications.create(about_user: @copy.buyer, state: "copy requested", commission: @copy)

      pictures = @copy.pictures
      pictures.each do |picture|
        @commission.pictures.create!(picture: picture.picture)
      end

      MessageThread.create!(:buyer_id => params[:buyer_id],
                            :seller_id => params[:seller_id],
                            :commission => @copy)

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
                           :pictures => @commission.pictures.dup,
                           :accepted_by_buyer => true,
                           :public => false)
    if @copy.save
      @copy.seller.notifications.create(about_user: @copy.buyer, state: "similar requested", commission: @copy)

      pictures = @copy.pictures
      pictures.each do |picture|
        @commission.pictures.create!(picture: picture.picture)
      end

      MessageThread.create!(:buyer_id => params[:buyer_id],
                            :seller_id => params[:seller_id],
                            :commission => @copy)

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

  def make_custom
    @copy = Commission.new(:name => params[:name],
                           :description => params[:description],
                           :price => params[:price],
                           :seller_id => params[:seller_id],
                           :buyer_id => params[:buyer_id],
                           :state => 'discussion',
                           :category_id => params[:category_id],
                           :accepted_by_buyer => true,
                           :public => false)
    if @copy.save
      @copy.seller.notifications.create(about_user: @copy.buyer, state: "new requested", commission: @copy)

      MessageThread.create!(:buyer_id => params[:buyer_id],
                            :seller_id => params[:seller_id],
                            :commission => @copy)

      respond_to do |format|
        format.html { redirect_to user_profile_path(params[:seller_id]), notice: 'Your request was successfully sent.' }
        format.json { render :show, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to custom_commission_path(params[:seller_id]), alert: 'There was an error sending your request. Please try again.' }
        format.json { render json: @commission.errors, status: :unprocessable_entity }
      end
    end
  end

  def custom
    @page_title = "Request custom commission"
    @seller = User.find(params[:id])
    @commission = Commission.new
    @categories = Category.all
  end

  def approve
    @commission = Commission.find(params[:id])
    @commission.accept!(current_user)
    @commission.seller.notifications.find_by(commission: @commission).destroy if @commission.seller.notifications.find_by(commission: @commission)
    @commission.buyer.notifications.find_by(commission: @commission).destroy if @commission.buyer.notifications.find_by(commission: @commission)
    @commission.buyer.notifications.create(about_user: current_user, commission: @commission, state: "request accepted");
    redirect_to @commission
  end

  def mark_shipped
    @commission = Commission.find(params[:id])
    @commission.update_attributes!(state: "shipped")
    @commission.seller.notifications.find_by(commission: @commission).destroy
    @commission.buyer.notifications.create(about_user: @commission.seller, commission: @commission, state: "item delivered")
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
