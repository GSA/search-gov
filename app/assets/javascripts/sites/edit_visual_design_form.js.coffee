setPosition = () ->
  $('#primary-header-links .position').each (index) ->
    $(this).val index
  $('#secondary-header-links .position').each (index) ->
    $(this).val index
  $('#footer-links .position').each (index) ->
    $(this).val index
  $('#identifier-links .position').each (index) ->
    $(this).val index

$(document).on 'submit', '#edit-visual-designs', setPosition

setupVisualDesignFormDnD = () ->
  $('#primary-header-links,
    #secondary-header-links,
    #footer-links,
    #identifier-links').tableDnD
    onDrop: window.usasearch.enablePrimaryButton,
    onDragClass: 'ondrag',
    dragHandle: '.draggable'

window.usasearch.setupVisualDesignFormDnD ?= setupVisualDesignFormDnD
$(document).on 'turbolinks:load', setupVisualDesignFormDnD
