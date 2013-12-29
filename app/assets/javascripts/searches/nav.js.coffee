toggleCollapsed = (e) ->
  e.preventDefault()
  $('#nav-dropdown').toggleClass 'collapsed'

$(document).on 'click', '#nav-dropdown > a', toggleCollapsed
