class PagesController < ApplicationController
  def contact_us
    @page_title = "Contact us"
  end

  def welcome
  end

  def faq
    @page_title = "FAQ"
  end
end
