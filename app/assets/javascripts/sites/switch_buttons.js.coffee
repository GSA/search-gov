ready = () ->
  notIE7 = "postMessage" of window;
  $('.switch-button').addClass 'make-switch' if notIE7

$(document).ready ready
$(document).on 'page:load', ready

makeSwitch = () ->
  $('.make-switch')['bootstrapSwitch']();
$(document).on 'page:load', makeSwitch
