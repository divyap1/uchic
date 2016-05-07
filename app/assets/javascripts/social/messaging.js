(function() {
  var userId = $("meta[name=user_id]").attr("content");
  if (!userId) {
    return;
  }

  var messagePopups = [];

  function find(array, condition) {
    for (var i = 0; i < array.length; i++) {
      if (condition(array[i])) return array[i];
    }
  }

  function fetchMessages(partnerId, partnerName) {
    var popup = ensureMessagePopup({ partnerId: partnerId, partnerName: partnerName });

    $.get("/messages.json", { user_id: userId, partner_id: partnerId }, function(messages) {
      for (var i = 0; i < messages.length; i++) {
        if (messages[i].sender_id.toString() === userId.toString()) {
          addMessage({
            partnerId: messages[i].receiver_id,
            partnerName: messages[i].receiver_name,
            message: messages[i].message
          }, "sent");
        } else {
          addMessage({
            partnerId: messages[i].sender_id,
            partnerName: messages[i].sender_name,
            message: messages[i].message
          }, "received");
        }
      }
    });
  }

  function sendMessage(e) {
    var input = $(e.target);

    $.post("/messages.json", {
      message: {
        sender_id: userId,
        receiver_id: input.data("receiver"),
        message: input.val()
      }
    }, function() {
      addMessage({
        partnerId: input.data("receiver"),
        message: input.val()
      }, "sent");
      input.val("");
    });
  }

  function buildMessageBubble(data, type) {
    return $(
      "<div class='message " + type + "'>" +
        "<span class='content'>" + data.message + "</span>" +
      "</div>"
    );
  }

  function messageContainer(data) {
    return $(".message-container[data-sender=" + data.partnerId + "]");
  }

  function ensureMessagePopup(data) {
    var item = find(messagePopups, function(item) {
      return item.partnerId.toString() === data.partnerId.toString();
    });

    if (item) {
      return item.popup;
    } else {
      var popup = $(
        "<div class='message-popup'>" +
          "<h4>" + data.partnerName + "</h4>" +
          "<div class='messages'></div>" +
          "<input type='text' class='form-control' data-receiver='" + data.partnerId + "' placeholder='Type a message ...' />" +
        "</div>"
      );

      $("#message_popups").append(popup);
      popup.find("input").on("change", sendMessage);

      messagePopups.push({ partnerId: data.partnerId, popup: popup });

      return popup;
    }
  }

  function addMessage(data, type) {
    var container = messageContainer(data);

    if (container.length) {
      container.append(buildMessageBubble(data, type));
    }

    var popup = ensureMessagePopup(data);
    var messagesContainer = popup.find(".messages");
    messagesContainer.append(buildMessageBubble(data, type));
    messagesContainer.scrollTop(messagesContainer.height() + 1000);
  }

  var client = new Faye.Client("/socket");

  // This makes sure that there's only ever one subscription (so messages aren't received twice)
  try {
    client.unsubscribe("/messages");
  } catch(e) { }

  client.subscribe("/messages", function(data) {
    if (data.receiver_id.toString() === userId.toString()) {
      addMessage({
        partnerId: data.sender_id,
        partnerName: data.sender_name,
        message: data.message
      }, "received");
    }
  });

  $(".start-message").on("click", function(e) {
    fetchMessages($(e.target).data("receiver"), $(e.target).data("receiver-name"));
  });
})();
