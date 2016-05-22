class PagesController < ApplicationController
  def contact_us
    @page_title = "Contact us"
  end

  def welcome
  	@commissions = Commission.publicly_visible.sample(3)
  end

  def faq
    @page_title = "FAQ"
  end
end
