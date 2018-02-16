ready = ->
  $('.l-site-nav.main a[data-toggle=tooltip], #pin-site[data-toggle=tooltip], #envelope-snapshot-toggle[data-toggle=tooltip], #filtered-analytics-toggle[data-toggle=tooltip]')
    .tooltip('destroy')
    .tooltip
      container: 'body',
      placement: 'right',
      trigger: 'hover'

$(document).on 'turbolinks:load', ready
