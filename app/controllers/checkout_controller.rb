class CheckoutController < ApplicationController
  def checkout
    @product = Product.find(params[:id])
    @shipping = 4.99;
    @quantity = 1;
    @subtotal = @product.price * @quantity;
  end

  #PUT
  def choose_quantity
    respond_to do |format|

    end
  end
end
