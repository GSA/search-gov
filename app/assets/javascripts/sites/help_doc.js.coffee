fillHelpLinkModal = (data) ->
  $('#help-doc .modal-body .content').append data.body
  $('#help-doc').modal 'show'

loadHelpDoc = (url) ->
  params = $.param({ url: url })
  helpLinkUrl = '/help_docs?' + params
  $.getJSON helpLinkUrl, fillHelpLinkModal

$(document).on 'click', '.help-link', () ->
  if $('#help-doc .modal-body .content').is(':empty')
    loadHelpDoc $(this).attr('href')
  else
    $('#help-doc').modal 'show'
  false
