ready = ->
  $('.l-site-nav.main a[data-toggle=tooltip], #pin-site[data-toggle=tooltip]').tooltip
    container: 'body',
    placement: 'right',
    trigger: 'hover'

$(document).ready(ready)
$(document).on 'page:load', ready
