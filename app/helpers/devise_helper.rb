module DeviseHelper
  def devise_error_messages!
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = "Sorry, you'll need to fix these errors before you can continue."

    html = <<-HTML
    <div class="alert alert-danger">
      <h4>#{sentence}</h4>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end
end
