modalContentSelector = '#help-doc .modal-body .modal-content'

fillHelpLinkModal = (data) ->
  $(modalContentSelector).append data.body
  $('#help-doc').modal 'show'

loadHelpDoc = (url) ->
  params = $.param({ url: url })
  helpLinkUrl = '/help_docs?' + params
  $.getJSON helpLinkUrl, fillHelpLinkModal

$(document).on 'click', '.help-link', () ->
  url = $(this).attr('href')
  $modalContentSelector = $(modalContentSelector)
  if $modalContentSelector.is(':empty') or $('#help-doc').data('url') isnt url
    $('#help-doc').data 'url', url
    $modalContentSelector.empty()
    loadHelpDoc url
  else
    $('#help-doc').modal 'show'
  false
