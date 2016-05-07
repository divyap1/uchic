json.array!(@messages) do |message|
  json.extract! message, :id, :sender_id, :receiver_id, :message
  json.url message_url(message, format: :json)
end
