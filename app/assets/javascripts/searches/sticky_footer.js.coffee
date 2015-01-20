setupStickyFooter = ->
  return unless $('#footer-wrapper').length > 0
  setMargin()
  $(window).on 'resize', setMargin

setMargin = ->
  if $('body').outerWidth(true) >= 768
    footerHeight = $('#footer-wrapper').outerHeight(true)
    $('#main-content').css 'paddingBottom', footerHeight
  else
    $('#main-content').css 'paddingBottom', 0

$(document).ready setupStickyFooter
