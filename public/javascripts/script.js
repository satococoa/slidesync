// show player
window.flashMovie;

//Load the flash player. Properties for the player can be changed here.
function loadPlayer(doc) {
  //allowScriptAccess from other domains
  var params = { allowScriptAccess: "always" };
  var atts = { id: "slide" };

  //doc: The path of the file to be used
  //startSlide: The number of the slide to start from
  //rel: Whether to show a screen with related slideshows at the end or not. 0 means false and 1 is true..
  var flashvars = { doc : doc, startSlide : 1, rel : 0 };

  //Generate the embed SWF file
  swfobject.embedSWF("http://static.slidesharecdn.com/swf/ssplayer2.swf", "slide", "598", "480", "8", null, flashvars, params, atts, function(){
    window.flashMovie = document.getElementById('slide');
    console.log(window.flashMovie);
  });
}

//Jump to the appropriate slide
function jumpTo(page){
  if (page == 'last') {
    window.flashMovie.last();
  } else {
    window.flashMovie.jumpTo(page);
  }
}

//Update the slide number in the field for the same
function currentPage(){
  return window.flashMovie.getCurrentSlide();
}

function publishJumpTo(page) {
  var url = '/slide/'+window.slide_id+'/'+page;
  $.post(url, {_method: 'PUT'});
}


$(function() {
  loadPlayer(window.slide_doc);

  $('#first').click(function(e) {
    publishJumpTo(1);
  });
  $('#prev').click(function(e) {
    publishJumpTo(currentPage() - 1);
  });
  $('#next').click(function(e) {
    publishJumpTo(currentPage() + 1);
  });
  $('#last').click(function(e) {
    publishJumpTo('last');
  });
  $('#gotoBox').keyup(function(e) {
    if (e.keyCode == 13) {
      publishJumpTo($('#gotoBox').val());
    }
  });

  // memberListHeight
  var memberListHeight = function() {
    var $sidebar = $( '#sidebar' );
    var $memberList = $( '#memberList' );

    var setHeight = function() {
      var winHeight = $( window ).height();
      var headerHeight = $( '#header' ).outerHeight();
      var searchAndLogin = $sidebar.find( 'div:first' ).outerHeight();
      var listHeight = winHeight - headerHeight - searchAndLogin;
      $memberList.css({
        height: listHeight + 'px'
      });
    };
    setHeight();

    $( window ).resize(function() {
      setHeight();
    });
  };
  memberListHeight();
});
