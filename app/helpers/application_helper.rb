module ApplicationHelper
  def user_rating(user)
    stars = user.rating.to_i.times.map { content_tag("span", "", class: "glyphicon glyphicon-star") }

    stars.join.html_safe
  end

  def price_display(commission)
    seller_country_code = ISO3166::Country.find_country_by_name(commission.seller.country_name).currency.code
    user_country_code = ISO3166::Country.find_country_by_name(current_user.country_name).currency.code if user_signed_in?
    user_country_code ||= "NZD"

    price = Money.new(commission.price * 100, seller_country_code).exchange_to(user_country_code)
    Money.new(price, user_country_code).format
  end
end
