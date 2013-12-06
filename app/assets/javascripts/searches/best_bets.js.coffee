toggleCollapsed = () ->
  $('#best-bets').toggleClass 'collapsed'

$(document).on 'click', '.show-less, .show-more', toggleCollapsed
