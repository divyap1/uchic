class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
    @products = @products.starts_with(params[:search]) if params[:search].present?
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
    
    #Must be signed in to add a product
    unless user_signed_in?
        @product.errors.add(:permission, 'You must be logged in to perform this action.')
    end
  end

  # GET /products/1/edit
  def edit

    #Can only edit products you added
    unless user_signed_in? && @product.seller_id == current_user.id
      @product.errors.add(:permission, 'You do not have permission to edit this product.')
    end 

  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy

    String notice = "";

    #Check the current user posted the product
    if user_signed_in? && @product.seller_id == current_user.id
      @product.destroy
      notice = 'Product was successfully destroyed.'
    else
      notice = 'You do not have permissions to delete this item.'
    end 

   respond_to do |format|
      format.html { redirect_to products_url, notice: notice }
      format.json { head :no_content }
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :description, :price, :quantity, :seller_id)
    end
end
