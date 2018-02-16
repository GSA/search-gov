onKeyUpWithoutSpecialKeys = (e) ->
  window.usasearch.enablePrimaryButton() unless (e.which in [9, 16, 17, 18, 91])

textSelector = ['.form textarea',
                '.form input[type="email"]',
                '.form input[type="password"]',
                '.form input[type="radio"]',
                '.form input[type="text"]',
                '.form input[type="url"]'].toString()

$(document).on 'keyup',
  textSelector,
  onKeyUpWithoutSpecialKeys

onChangeSelector = [textSelector,
                    '.form input[type="checkbox"]',
                    '.form input[type="file"]',
                    '.form input[type="radio"]',
                    '.form select'].toString()

$(document).on 'change',
  onChangeSelector,
  window.usasearch.enablePrimaryButton

showDatePicker = ->
  if $(this).hasClass('calendar')
    dateField = $(this).find('input').first()
    $(dateField).datepicker 'show'

$(document).on 'click', '.form .calendar', showDatePicker

ready = ->
  $('.form input[data-toggle=tooltip]')
    .tooltip('destroy')
    .tooltip
      container: '.form',
      placement: 'right',
      trigger: 'focus'

  $('.form[id^="new_"] input.input-primary').focus()

$(document).on 'page:change turbolinks:load ready', ready
