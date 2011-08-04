jQuery(document).ready(function() {
  var height = document.body.clientHeight || document.body.offsetHeight || document.body.scrollHeight;
  var width = document.body.clientWidth || document.body.offsetWidth || document.body.scrollWidth;
  parent.socket.postMessage(width + " " + height);

  jQuery('#popular_urls a').targetTop();
  jQuery('.searchresult a').targetTop();
});
