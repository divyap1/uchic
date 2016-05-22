module ApplicationHelper
  def user_rating(user)
    stars = user.rating.to_i.times.map { content_tag("span", "", class: "glyphicon glyphicon-star") }

    stars.join.html_safe
  end
end
