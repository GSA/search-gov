sortPositions = () ->
  $('#no-results-pages-alt-links .position').each (index) ->
    $(this).val index

$(document).on 'submit', '#edit-no-results-pages', sortPositions

setupNoResultsPagesLinksDnD = () ->
  $('#no-results-pages-alt-links').tableDnD
    onDrop: window.usasearch.enablePrimaryButton,
    onDragClass: 'ondrag',
    dragHandle: '.draggable'

window.usasearch.setupNoResultsPagesLinksDnD ?= setupNoResultsPagesLinksDnD
$(document).ready setupNoResultsPagesLinksDnD
$(document).on 'page:load', setupNoResultsPagesLinksDnD
