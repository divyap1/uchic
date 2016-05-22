class PagesController < ApplicationController
  def contact_us
  end

  def welcome
  	@commissions = Commission.publicly_visible.sample(3)
  end

  def faq
  end
end
