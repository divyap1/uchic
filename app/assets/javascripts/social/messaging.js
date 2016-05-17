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

  function fetchMessages(popup, threadId) {
    $.get("/message_threads/" + threadId + ".json", function(thread) {
      var messages = thread.messages;

      for (var i = 0; i < messages.length; i++) {
        if (messages[i].sender_id.toString() === userId.toString()) {
          addMessage({
            threadId: messages[i].message_thread_id,
            partnerName: messages[i].receiver_name,
            message: messages[i].message,
            commission: messages[i].commission
          }, "sent");
        } else {
          addMessage({
            threadId: messages[i].message_thread_id,
            partnerName: messages[i].sender_name,
            message: messages[i].message,
            commission: messages[i].commission
          }, "received");
        }
      }

      if (thread.commission && thread.commission.mini_view) {
        popup.find(".thread-commission").replaceWith(thread.commission.mini_view);
      }
    });
  }

  function maybeSendMessage(e) {
    if (e.which !== 13 || !$(e.target).val()) return;

    e.preventDefault();

    var input = $(e.target);

    $.post("/messages.json", {
      message: {
        message_thread_id: input.data("thread"),
        sender_id: userId,
        message: input.val()
      }
    }, function() {
      addMessage({
        threadId: input.data("thread"),
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

  function messageContainer(threadId) {
    return $(".message-container[data-thread=" + threadId + "]");
  }

  function findMessagePopup(data) {
    var item = find(messagePopups, function(item) {
      return item.threadId.toString() === data.threadId.toString();
    });

    if (item) {
      return item.popup;
    }
  }

  function createMessagePopup(data) {
    var popup = $(
      "<div class='message-popup'>" +
        "<h4>" +
          "<span class='new-indicator glyphicon glyphicon-asterisk' aria-hidden='true'></span> " +
          data.partnerName +
          "<button class='close delete'><span class='glyphicon glyphicon-remove'></span></button>" +
          "<button class='close minimise'><span class='glyphicon glyphicon-minus'></span></button>" +
        "</h4>" +
        "<div class='thread-commission'></div>" +
        "<div class='messages'></div>" +
        "<textarea rows='2' class='form-control' data-thread='" + data.threadId + "' placeholder='Type a message ...'></textarea>" +
      "</div>"
    );

    $("#message_popups").append(popup);

    var index = messagePopups.length;
    messagePopups.push({ threadId: data.threadId, popup: popup });

    popup.find("textarea").on("keypress", maybeSendMessage);

    popup.on("click", function() { popup.removeClass("new"); });
    popup.find(".minimise").on("click", function() { popup.toggleClass("minimised"); });
    popup.find(".delete").on("click", function() {
      messagePopups.splice(index, 1);
      popup.remove();
    });

    fetchMessages(popup, data.threadId);

    return popup;
  }

  function ensureMessagePopup(data) {
    var popup = findMessagePopup(data);

    if (popup) {
      return popup;
    }

    return createMessagePopup(data);
  }

  function addMessage(data, type) {
    var container = messageContainer(data.threadId);

    if (container.length) {
      container.find(".messages").append(buildMessageBubble(data, type));
      return;
    }

    var popup = findMessagePopup(data);
    if (!popup) {
      return createMessagePopup(data);
    }

    if (data.highlight) {
      popup.addClass("new");
    }

    var messagesContainer = popup.find(".messages");
    messagesContainer.append(buildMessageBubble(data, type));
    messagesContainer.scrollTop(messagesContainer.height() + 1000);
  }

  function updateCommission(container, newHtml) {
    container.find(".thread-commission").replaceWith(newHtml);
    container.find(".thread-commission").addClass("modified");
  }

  var client = new Faye.Client("/socket");

  // This makes sure that there's only ever one subscription (so messages aren't received twice)
  try {
    client.unsubscribe("/messages");
    client.unsubscribe("/commissions");
  } catch(e) { }

  client.subscribe("/messages", function(data) {
    if (data.receiver_id.toString() === userId.toString()) {
      addMessage({
        threadId: data.message_thread_id,
        partnerName: data.sender_name,
        message: data.message,
        commission: data.commission,
        highlight: true
      }, "received");
    }
  });

  client.subscribe("/commissions", function(data) {
    if (data.seller_id.toString() === userId.toString() ||
        (data.buyer_id && data.buyer_id.toString() === userId.toString())) {
      var container = messageContainer(data.message_thread.id);

      if (container.length) {
        return updateCommission(container, data.full_view);
      }

      var popup = ensureMessagePopup({
        threadId: data.message_thread.id,
        partnerName: data.message_thread.seller_name
      });

      updateCommission(popup, data.mini_view);
    }
  });

  $(".start-message").on("click", function(e) {
    $.post("/message_threads.json?" + $.param({
      message_thread: { seller_id: $(e.target).data("seller") }
    }), function(thread) {
      ensureMessagePopup({
        threadId: thread.id,
        partnerName: thread.seller_name
      });
    });
  });

  $(".message-input").on("keypress", maybeSendMessage);

  $(".message-container").each(function() {
    $(this).scrollTop($(this).height() + 1000);
  });
})();
