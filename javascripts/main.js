// Check if a new cache is available on page load.
window.addEventListener('load', function(e) {

  window.applicationCache.addEventListener('updateready', function(e) {
    if (window.applicationCache.status == window.applicationCache.UPDATEREADY) {
      // Browser downloaded a new app cache.
      // Swap it in and reload the page to get the new hotness.
      window.applicationCache.swapCache();
      //if (confirm('A new version of this site is available. Load it?')) {
        window.location.reload();
      //}
    } else {
      // Manifest didn't changed. Nothing new to server.
    }
  }, false);

}, false);