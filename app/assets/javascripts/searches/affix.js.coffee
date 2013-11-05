isNavVisible = () ->
  $('#main-nav.sticky').length > 0

affix = () ->
  lastScroll = $(document).data 'last-scroll'
  lastScroll = 0 unless lastScroll?
  currentScroll = $(@).scrollTop()
  $(document).data 'last-scroll', currentScroll

  isScrollingUp = currentScroll < lastScroll
  isStickyNavVisible = $('#main-nav.sticky').length > 0

  if isScrollingUp and currentScroll > 0
    if !isStickyNavVisible and currentScroll > $(window).height()
      $('#main-nav').addClass 'sticky'
  else
    $('#main-nav').removeClass 'sticky'

$(document).on 'scroll', affix
