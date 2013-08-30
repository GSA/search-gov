$(document).on 'hide', '#preview', () ->
  $('body').removeClass 'preview'

fillPreviewModal = (data) ->
  $('#preview').replaceWith data
  $('body').addClass 'preview'
  $('#preview').modal backdrop: false

loadPreview = (url) ->
  $.get url, fillPreviewModal, 'html'

$(document).on 'click', '#preview-trigger', () ->
  url = $(this).data 'url'
  loadPreview url
  false

$(document).on 'click', '#preview .nav a[target="preview-frame"]', ()->
  $('#preview .navbar .nav li.active').removeClass 'active'
  $(this).parent().addClass 'active'
