ready = ->
  $('.form input[type="text"], .form textarea').on 'keydown',
    window.usasearch.enablePrimaryButton
  $('.form input[type="text"], .form textarea').on 'paste',
    window.usasearch.enablePrimaryButton
  $('.form input[type="file"]').on 'change',
    window.usasearch.enablePrimaryButton

$(document).on 'turbolinks:load', ready
