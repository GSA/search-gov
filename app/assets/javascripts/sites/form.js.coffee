enablePrimaryButton = (e) ->
  disabled = $('.form .btn.submit.disabled')
  $(disabled).removeAttr 'disabled'
  $(disabled).removeClass 'disabled'
  $(disabled).addClass 'btn-primary'
  true

$(document).on 'keydown',
  '.form input[type="text"], .form input[type="url"], .form textarea',
  enablePrimaryButton
$(document).on 'paste',
  '.form input[type="text"], .form input[type="url"], .form textarea',
  enablePrimaryButton
$(document).on 'change',
  '.form input[type="file"], .form input[type="text"], .form input[type="url"], .form select',
  enablePrimaryButton

showDatePicker = (e) ->
  if $(this).hasClass('calendar')
    dateField = $(this).find('input').first()
    $(dateField).datepicker 'show'

$(document).on 'click', '.form .calendar', showDatePicker

ready = ->
  $('.form input.input-primary').focus()

$(document).ready ready
$(document).on 'page:change', ready
