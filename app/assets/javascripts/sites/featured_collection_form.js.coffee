sortPositions = () ->
  $('#featured-collection-links .position').each (index) ->
    $(this).val index

$(document).on 'submit', 'form[id^=edit_featured_collection],form[id^=new_featured_collection]', sortPositions

setupFeaturedCollectionLinksDnD = () ->
  $('#featured-collection-links').tableDnD
    onDrop: window.usasearch.enablePrimaryButton,
    onDragClass: 'ondrag',
    dragHandle: '.draggable'

window.usasearch.setupFeaturedCollectionLinksDnD ?= setupFeaturedCollectionLinksDnD
$(document).on 'turbolinks:load', setupFeaturedCollectionLinksDnD
