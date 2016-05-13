class CheckoutController < ApplicationController
  def checkout
    @commission = Commission.find(params[:id])
    @shipping = 4.99;
    @subtotal = @commission.price;
  end
end
