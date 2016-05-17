module MessageThreadsHelper
  include CommissionsHelper

  def thread_data(thread)
    thread.attributes.merge(
      seller_name: thread.seller.name,
      messages: thread.messages.map(&:detailed_attributes),
      commission: thread.commission && commission_data(thread.commission)
    )
  end
end
