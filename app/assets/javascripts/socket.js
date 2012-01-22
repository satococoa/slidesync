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
  channel.bind('enter', function(user) {
    var $members = $('#memberList');
    $members.append($('<li/>').attr('id', user.nickname).text('@'+user.nickname));
    adjustMemberListHeight();
  });
  channel.bind('exit', function(user) {
    $('#memberList').find('#'+user.nickname).remove();
    adjustMemberListHeight();
  });
});
