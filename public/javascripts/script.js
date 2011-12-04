$(function() {
  // show player
  var flashMovie;

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
    swfobject.embedSWF("http://static.slidesharecdn.com/swf/ssplayer2.swf", "slide", "598", "480", "8", null, flashvars, params, atts);

    //Get a reference to the player
    flashMovie = document.getElementById("player");
  }

  //Jump to the appropriate slide
  function jumpTo(){
    flashMovie.jumpTo(parseInt(document.getElementById("slidenumber").value));
  }

  //Update the slide number in the field for the same
  function updateSlideNumber(){
    document.getElementById("slidenumber").value = flashMovie.getCurrentSlide();
  }
});
