window.addEventListener('load', function() {
  var events = [
    'cached',
    'checking',
    'downloading',
    'error',
    'noupdate',
    'obsolete',
    // 'progress',
    // 'updateready',
  ];
  for (i in events) {
    window.applicationCache.addEventListener(events[i], function(name, e) {
      console.log(name);
      console.log(e);
    }.bind(this, events[i]));
  }

  window.applicationCache.addEventListener('updateready', function() {
    window.location.reload();
  });
});
