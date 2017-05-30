exports.runJwplayer = function(vid) {
  return function() {
    var playerInstance = jwplayer("video");
    playerInstance.setup({
      file: "https://www.youtube.com/watch?v=" + vid,
      title: '',
      aspectratio: '16:9',
      stretching: 'uniform',
      height: '100%',
      width: '81%',
      autostart:'false',
      wmode:'opaque',
      primary: 'html5',
      displaytitle:'false',
      displaydescription:'false',
    });
  }
}

