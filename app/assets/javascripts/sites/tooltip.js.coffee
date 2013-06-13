ready = ->
  $('.l-site-nav.main a[data-toggle=tooltip]').tooltip
    container: 'body',
    placement: 'right'

$(document).ready(ready)
$(document).on 'page:load', ready
