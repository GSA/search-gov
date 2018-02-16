processEditDisplayForm = () ->
  $('#sidebar .position').each (index) ->
    $(this).val index
  $('#related-sites .position').each (index) ->
    $(this).val index

$(document).on 'submit', '#edit-display', processEditDisplayForm

setupDisplayFormDnD = () ->
  $('#related-sites, #sidebar').tableDnD
    onDrop: window.usasearch.enablePrimaryButton,
    onDragClass: 'ondrag',
    dragHandle: '.draggable'

window.usasearch.setupDisplayFormDnD ?= setupDisplayFormDnD
$(document).on 'turbolinks:load', setupDisplayFormDnD
