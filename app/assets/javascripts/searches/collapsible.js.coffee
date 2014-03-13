toggleCollapsed = (e) ->
  if (e.which? and e.which == 13) or (e.type == 'click')
    e.preventDefault()
    $target = $(this).parents('.collapsible')
    $target.toggleClass 'collapsed'
    $(this).siblings('.show-less, .show-more').focus()

$(document).on 'click keypress', '#search .show-less, .show-more', toggleCollapsed
