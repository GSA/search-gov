ready = ->
  $('#pin-site .description, #envelope-snapshot-toggle .description').removeClass('off-screen-text')

$(document).ready(ready)
$(document).on 'page:load', ready
