toggleCollapsed = (e) ->
  e.preventDefault()
  $target = $(this).parents('.collapsible')
  $target.toggleClass 'collapsed'

$(document).on 'click', '.show-less, .show-more', toggleCollapsed
