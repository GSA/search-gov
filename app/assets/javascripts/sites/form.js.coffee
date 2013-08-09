enablePrimaryButton = (e) ->
  disabled = $('.form .btn.submit.disabled')
  $(disabled).removeAttr 'disabled'
  $(disabled).removeClass 'disabled'
  $(disabled).addClass 'btn-primary'
  true

$(document).on 'keydown', '.form input[type="text"]', enablePrimaryButton
$(document).on 'change', '.form input[type="file"]', enablePrimaryButton
