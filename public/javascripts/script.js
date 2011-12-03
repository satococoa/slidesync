$(function() {
  Pusher.log = function(message) {
    if (window.console && window.console.log) window.console.log(message);
  };
  
  var pusher = new Pusher(window.pusher_key);
  var channel = pusher.subscribe('test_channel');
  channel.bind('my_event', function(data) {
    alert(data);
  });
});
