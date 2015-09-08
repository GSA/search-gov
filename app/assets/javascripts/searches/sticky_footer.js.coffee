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

windowLoadEvent = (func) ->
  oldOnLoad = window.onload
  unless typeof window.onload is "function"
    window.onload = func
  else
    window.onload = ->
      oldOnLoad()
      func()

windowLoadEvent setupStickyFooter
