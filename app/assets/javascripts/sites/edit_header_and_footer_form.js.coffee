sortPositions = () ->
  $('#header-links .position').each (index) ->
    $(this).val index
  $('#footer-links .position').each (index) ->
    $(this).val index

$(document).on 'submit', '#edit-header-and-footer', sortPositions

enableMakeLiveButton = () ->
  disabled = $('#edit-header-and-footer #make-live.disabled, #edit-header-and-footer .btn.dropdown-toggle')
  $(disabled).prop 'disabled', false
  $(disabled).removeClass 'disabled'

$(document).on 'keydown', '.form textarea', enableMakeLiveButton
$(document).on 'paste', '.form textarea', enableMakeLiveButton

setupHeaderAndFooterLinksDnD = () ->
  $('#header-links, #footer-links').tableDnD
    onDrop: window.usasearch.enablePrimaryButton,
    onDragClass: 'ondrag',
    dragHandle: '.draggable'

window.usasearch.setupHeaderAndFooterLinksDnD ?= setupHeaderAndFooterLinksDnD
$(document).on 'turbolinks:load', setupHeaderAndFooterLinksDnD
