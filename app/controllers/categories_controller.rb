class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.all
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @display_sizes = [6, 12, 24]
    @display_size = params[:display_size] || @display_sizes.first
    @display_size.to_i

    @category = Category.find(params[:id])
    all_items = @category.commissions + @category.children.flat_map(&:commissions)

    @order_options = ["Price low to high", "Price high to low", "Name", "Recently added"]
    @order = params[:order] || @order_options.first

    if @order == "Price low to high"
      all_items.sort_by!(&:price)
    elsif @order == "Price high to low"
      all_items.sort_by!(&:price).reverse!
    elsif @order == "Name"
      all_items.sort_by!(&:name)
    elsif @order == "Recently added"
      all_items.sort_by!(&:created_at).reverse!
    end

    @commissions = Kaminari.paginate_array(all_items).page(params[:page]).per(@display_size)

    @section = @category.name
    @ancestry = @category.ancestors

    @top_sellers = all_items.map(&:seller).first(3);
  end

  # GET /categories/new
  def new
    @Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: 'Category was successfully created.' }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: 'Category was successfully updated.' }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_url, notice: 'Category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.fetch(:category, {})
    end
end
