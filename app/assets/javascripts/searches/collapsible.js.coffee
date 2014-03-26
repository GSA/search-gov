setFocusWhenExpanded = ($collapsible) ->
  if $collapsible.hasClass 'focus-on-next-sibling'
    if window.lastIdWithFocus?
      nextSibling = $("##{window.lastIdWithFocus}").next()
      nextSibling.find('a').first().focus()
  else
    $('.show-less', $collapsible).focus()

setFocusOnShowMore = ($collapsible) ->
  $collapsible.focus() if $collapsible.hasClass 'focus-on-next-sibling'
  $('.show-more', $collapsible).focus()

toggleCollapsed = (e) ->
  if (e.which? and e.which == 13) or (e.type == 'click')
    e.preventDefault()
    $collapsible = $(this).parents('.collapsible')
    isCollapsed = $collapsible.hasClass 'collapsed'
    $collapsible.toggleClass 'collapsed'
    if isCollapsed
      setFocusWhenExpanded $collapsible
    else
      setFocusOnShowMore $collapsible

$(document).on 'click keypress', '#search .show-less, .show-more', toggleCollapsed

onFocus = (e) ->
  lastElementWithId = $(e.currentTarget).parents('*[id]').first()
  currentFocusId = lastElementWithId.attr('id') if lastElementWithId? && $('a', lastElementWithId).length > 0
  window.lastIdWithFocus = currentFocusId if currentFocusId?

$(document).on 'focus', '#jobs.collapsed h3 a', onFocus
