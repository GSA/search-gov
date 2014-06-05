itemSelector = '#results.images .result.image .thumbnail a'

addResizeHandler = ->
  if eligibleForResizeHandler()
    assignHeight()
    $(window).on 'resize', assignHeight

eligibleForResizeHandler = ->
  $items = $(itemSelector)

  return true if $items.length > 0
  false

assignHeight = ->
  $items = $(itemSelector)
  itemWidth = $($items[0]).outerWidth()
  $items.css 'height', itemWidth

$(document).ready addResizeHandler
