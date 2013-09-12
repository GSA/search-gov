$(document).on 'keydown',
  '.form input[type="text"], .form input[type="url"], .form textarea',
  window.usasearch.enablePrimaryButton
$(document).on 'paste',
  '.form input[type="text"], .form input[type="url"], .form textarea',
  window.usasearch.enablePrimaryButton
$(document).on 'change',
  ' .form input[type="checkbox"], .form input[type="file"], .form input[type="radio"], .form input[type="text"], .form input[type="url"], .form select',
  window.usasearch.enablePrimaryButton

showDatePicker = () ->
  if $(this).hasClass('calendar')
    dateField = $(this).find('input').first()
    $(dateField).datepicker 'show'

$(document).on 'click', '.form .calendar', showDatePicker

ready = ->
  $('.form[id^="new_"] input.input-primary').focus()

$(document).ready ready
$(document).on 'page:change', ready
