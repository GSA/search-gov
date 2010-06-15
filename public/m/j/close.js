function toggleSearchClose() {
  var closeImage = $$(".dvSearchClose img")[0];
  if ($$('.auto_complete')[0].visible()) {
    closeImage.show();
  } else {
    closeImage.hide();
  }
  setTimeout("toggleSearchClose()", 100);
}

document.observe("dom:loaded", function() {
  toggleSearchClose();
});