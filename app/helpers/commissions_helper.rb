module CommissionsHelper
  def commission_data(commission)
    commission.attributes.merge(
      message_thread: commission.message_thread.try!(:detailed_attributes),
      mini_view: render_to_string(partial: "message_threads/commission_mini", locals: { commission: commission }),
      full_view: render_to_string(partial: "message_threads/commission_full", locals: { commission: commission })
    )
  end
end
