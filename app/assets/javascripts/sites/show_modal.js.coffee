showModal = (container) ->
  $(container).modal('show');

$(document).on 'click', '.modal-page-viewer-link', () ->
  container = $(this).data 'container'
  title = $(this).data 'title'
  $("#{container} .modal-header .title").html title

  selector = $(this).data 'selector'
  url = "#{$(this).attr('href')} #{selector}"

  $("#{container} .modal-body .content").load url, () ->
    showModal(container)
  false
