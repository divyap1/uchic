class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  # GET /orders.json
  def index
    if user_signed_in?
      @orders = Order.where(buyer_id: current_user.id)
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    unless user_signed_in? && @order.buyer_id == current_user.id
      @order.errors.add(:permission, 'You do not have permission to view this order.')
    end
  end

  # GET /orders/new/1
  def new
    unless user_signed_in?
       flash.now[:alert] = "Guests can not order products."
    end

    @commission = Commission.find(params[:id])
    @category = Category.find(@commission.category_id)
    @ancestry = @category.ancestors << @category
    @new_commission = Commission.new
  end

  # GET /orders/1/edit
  # def edit
  # end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # # PATCH/PUT /orders/1
  # # PATCH/PUT /orders/1.json
  #  def update
  #   respond_to do |format|
  #     if @order.update(order_params)
  #       format.html { redirect_to @order, notice: 'Order was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @order }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @order.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /orders/1
  # # DELETE /orders/1.json
  # def destroy
  #   @order.destroy
  #   respond_to do |format|
  #     format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:buyer_id)
    end
end
