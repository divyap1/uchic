module CommissionsHelper
  def commission_data(commission)
    commission.attributes.merge(
      message_thread: commission.message_thread.attributes,
      mini_view: render_to_string(partial: "message_threads/commission_mini", locals: { commission: commission }, formats: [:html]),
      full_view: render_to_string(partial: "message_threads/commission_full", locals: { commission: commission }, formats: [:html])
    )
  end
end
