fillHelpLinkModal = (data) ->
  $('#help-doc .modal-body .content').append data.body
  $('#help-doc').modal 'show'

loadHelpDoc = (url) ->
  params = $.param({ url: url })
  helpLinkUrl = '/help_docs?' + params
  $.getJSON helpLinkUrl, fillHelpLinkModal

$(document).on 'click', '.help-link', () ->
  url = $(this).attr('href')
  contentSelector = '#help-doc .modal-body .content'
  if $(contentSelector).is(':empty') or $('#help-doc').data('url') isnt url
    $('#help-doc').data 'url', url
    $(contentSelector).empty()
    loadHelpDoc url
  else
    $('#help-doc').modal 'show'
  false
