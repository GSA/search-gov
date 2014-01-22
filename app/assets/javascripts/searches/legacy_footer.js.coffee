setupFooter = ->
  $footer = $('#usasearch_footer')
  return unless $footer.length

  footerHeight = $footer.outerHeight(true)
  return unless footerHeight > 0

  if !$.support.transition
    $.fn.transition = jQuery.fn.animate

  containerWidth = $('#container').innerWidth()
  $('#usasearch_footer').css
    margin: '0 auto',
    width: containerWidth

  maxFooterHeight = Math.min(footerHeight, $(window).outerHeight(true) - 40);
  $('#usasearch_footer_container').data(maxFooterHeight: maxFooterHeight)

  $('#usasearch_footer_button').show()

$(window).on 'load', setupFooter

showFooter = (element) ->
  maxFooterHeight = $('#usasearch_footer_container').data('maxFooterHeight')

  $element = $(element)

  $element
    .transition(bottom: maxFooterHeight)
    .html('&#9650;')
    .attr('title', $element.data('hideText'))

  $('#usasearch_footer_container').transition { height: maxFooterHeight }

hideFooter = (element) ->
  $('#usasearch_footer_container')
  .transition(height: 0)

  $element = $(element)
  $element
    .transition(bottom: 0)
    .html('&#9660;')
    .attr('title', $element.data('showText'))

toggleFooter = (e) ->
  e.preventDefault()
  $footerContainer = $('#usasearch_footer_container')
  if $footerContainer.data 'isHidden'
    $footerContainer.data('isHidden', false)
    showFooter this
  else
    $footerContainer.data('isHidden', true)
    hideFooter this

$(document).on 'click', '#usasearch_footer_button', toggleFooter
