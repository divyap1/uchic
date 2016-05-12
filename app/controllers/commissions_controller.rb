class CommissionsController < ApplicationController
  before_action :set_commission, only: [:show, :edit, :update, :destroy]

  # GET /commissions
  # GET /commissions.json
  def index
    @commissions = Commission.all
    @commissions = @commissions.contains(params[:search]) if params[:search].present?
    @commissions = Kaminari.paginate_array(@commissions).page(params[:page]).per(params[:display_size])
  end

  # GET /commissions/1
  # GET /commissions/1.json
  def show
    @commission = Commission.find(params[:id])
    @category = Category.find(@commission.category_id)
    @seller = @commission.seller
    @ancestry = @category.ancestors << @category
    @section = @commission.name

    @similar_items = @category.commissions.order("RANDOM()").limit(3)
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
        pictures = params[:commission][:pictures]
        pictures.each do |picture|
          @commission.pictures.create!(picture: picture)
        end

        if @message_thread
          @message_thread.save!
          MessageBroadcastController.publish('/commissions', @commission.detailed_attributes)
        end

        format.html { redirect_to @commission, notice: 'commission was successfully created.' }
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
          MessageBroadcastController.publish('/commissions', @commission.detailed_attributes)
        end

        format.html { redirect_to @commission, notice: 'commission was successfully updated.' }
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
    if user_signed_in? && @commission.seller_id == current_user.id
      @commission.destroy
      respond_to do |format|
        format.html { redirect_to commissions_url, notice: 'commission was successfully destroyed.'}
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to commissions_url, alert: 'You do not have permissions to delete this item.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commission
      @commission = Commission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def commission_params
      params.require(:commission).permit(:name, :description, :price, :quantity, :seller_id, :picture, :category_id)
    end
end