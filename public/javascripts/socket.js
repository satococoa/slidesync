$(function() {
  // websocket
  Pusher.log = function(message) {
    if (window.console && window.console.log) window.console.log(message);
  };
  
  var pusher = new Pusher(window.pusher_key);
  var channel = pusher.subscribe(window.slide_id);
  channel.bind('jump_to', function(page) {
    jumpTo(page);
  });
});
