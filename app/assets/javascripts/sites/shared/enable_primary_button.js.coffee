enablePrimaryButton = () ->
  disabled = $('.form .btn.submit.disabled')
  $(disabled).prop 'disabled', false
  $(disabled).removeClass 'disabled'
  $(disabled).addClass 'btn-primary'
  true

window.usasearch.enablePrimaryButton ?= enablePrimaryButton
