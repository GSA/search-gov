itemSelector = '#results.images .result.image .thumbnail a'

addResizeHandler = ->
  if eligibleForResizeHandler()
    assignHeight()
    $(window).on 'resize', assignHeight

eligibleForResizeHandler = ->
  $items = $(itemSelector)

  if $items.length > 0
    vertical = $('#search').data('v')

    if vertical != 'image'
      return true

  false

assignHeight = ->
  $items = $(itemSelector)
  itemWidth = $($items[0]).outerWidth()
  $items.css 'height', itemWidth

$(document).ready addResizeHandler
