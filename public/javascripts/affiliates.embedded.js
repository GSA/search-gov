jQuery(document).ready(function() {
  parent.iframe.style.visibility = "visible";
  jQuery('#popular_urls a').targetTop();
  jQuery('.searchresult a').targetTop();
  var width = jQuery(document.body).width();
  var height = jQuery(document.body).height();
  parent.socket.postMessage(width + " " + height);
});
