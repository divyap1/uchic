module CommissionsHelper
  def commission_data(commission)
    commission.attributes.merge(
      message_thread: commission.message_thread.attributes,
      mini_view: render_to_string(partial: "message_threads/commission_mini", locals: { commission: commission }, formats: [:html]),
      full_view: render_to_string(partial: "message_threads/commission_full", locals: { commission: commission }, formats: [:html])
    )
  end

  def user_type(commission, you_option)
    if (current_user == commission.buyer && you_option == :buyer) ||
        (current_user == commission.seller && you_option == :seller)
      "you"
    elsif you_option == :seller
      commission.seller.first_name
    else
      commission.buyer.first_name
    end
  end
end
