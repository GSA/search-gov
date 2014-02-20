showModal = (container) ->
  $(container).modal('show');

$(document).on 'click', '.modal-page-viewer-link', (e) ->
  e.preventDefault()
  container = $(this).data 'modalContainer'
  title = $(this).data 'modalTitle'
  $("#{container} .modal-header .title").html title

  selector = $(this).data 'modalContentSelector'
  url = "#{$(this).attr('href')} #{selector}"

  $("#{container} .modal-body .modal-content").load url, () ->
    showModal(container)
  false
