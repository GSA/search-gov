showUrlModal = () ->
  $('#urls').modal('show');

$(document).on 'click', '.view-urls-link', () ->
  title = $(this).data('title')
  $('#urls .modal-header .title').html title
  url = $(this).attr('href') + ' .urls';
  $('#urls .modal-body .content').load(url, showUrlModal);
  false
