ready = () ->
  notIE7 = "postMessage" of window
  $('.switch-button').addClass 'make-switch' if notIE7
  $('.make-switch:not(.has-switch)')['bootstrapSwitch']()

$(document).on 'turbolinks:load', ready
