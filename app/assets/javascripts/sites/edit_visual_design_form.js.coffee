$(document).on 'submit', '#edit-visual-designs', ->
  $('.draggable-links .position').each (index) -> $(this).val index

setupVisualDesignFormDnD = ->
  $('.draggable-links').tableDnD
    onDrop: window.usasearch.enablePrimaryButton,
    onDragClass: 'ondrag',
    dragHandle: '.draggable'

window.usasearch.setupVisualDesignFormDnD ?= setupVisualDesignFormDnD
$(document).on 'turbolinks:load', setupVisualDesignFormDnD
