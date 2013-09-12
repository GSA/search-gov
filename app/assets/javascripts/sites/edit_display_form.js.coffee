processEditDisplayForm = () ->
  $('#sidebar .position').each (index) ->
    $(this).val index
  $('#related-sites .position').each (index) ->
    $(this).val index

$(document).on 'submit', '#edit-display', processEditDisplayForm

ready = () ->
  $('#related-sites, #sidebar').tableDnD
    onDrop: window.usasearch.enablePrimaryButton,
    onDragClass: 'ondrag',
    dragHandle: '.draggable'

$(document).ready ready
$(document).on 'page:load', ready
