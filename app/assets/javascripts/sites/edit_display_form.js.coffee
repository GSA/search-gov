processEditDisplayForm = () ->
  $('#sidebar .position').each (index) ->
    $(this).val index
  $('#related-sites .position').each (index) ->
    $(this).val index

$(document).on 'submit', '#edit-display', processEditDisplayForm

enablePrimaryButton = () ->
  disabled = $('.form .btn.submit.disabled')
  $(disabled).removeAttr 'disabled'
  $(disabled).removeClass 'disabled'
  $(disabled).addClass 'btn-primary'
  true

ready = () ->
  $('#related-sites, #sidebar').tableDnD
    onDrop: enablePrimaryButton,
    onDragClass: 'ondrag',
    dragHandle: '.draggable'

$(document).ready ready
$(document).on 'page:load', ready
