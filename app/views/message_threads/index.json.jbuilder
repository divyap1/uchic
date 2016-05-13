json.array!(@message_threads) do |message_thread|
  json.extract! message_thread, :id, :commission_id, :seller_id, :buyer_id
  json.url message_thread_url(message_thread, format: :json)
end
