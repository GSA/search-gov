enablePrimaryButton = (e) ->
  disabled = $('.form .btn.submit.disabled')
  $(disabled).removeAttr 'disabled'
  $(disabled).removeClass 'disabled'
  $(disabled).addClass 'btn-primary'
  true

ready = ->
  $('.form input[type="text"], .form textarea').on 'keydown', enablePrimaryButton
  $('.form input[type="text"], .form textarea').on 'paste', enablePrimaryButton
  $('.form input[type="file"]').on 'change', enablePrimaryButton

$(document).ready(ready)
$(document).on 'page:load', ready
