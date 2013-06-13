$(document).on 'keypress', '.form input[type="text"]', (e) ->
  disabled = $('.form .btn.submit[disabled]')
  $(disabled).removeAttr 'disabled'
  $(disabled).removeClass 'disabled'
  $(disabled).addClass 'btn-primary'
  true
