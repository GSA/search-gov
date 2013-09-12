enablePrimaryButton = () ->
  disabled = $('.form .btn.submit.disabled')
  $(disabled).removeAttr 'disabled'
  $(disabled).removeClass 'disabled'
  $(disabled).addClass 'btn-primary'
  true

window.usasearch.enablePrimaryButton ?= enablePrimaryButton
