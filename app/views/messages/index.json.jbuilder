json.array!(@messages) do |message|
  json.extract! message, :id, :sender_id, :receiver_id, :message
  json.sender_name message.sender.name
  json.receiver_name message.receiver.name
  json.url message_url(message, format: :json)
end
