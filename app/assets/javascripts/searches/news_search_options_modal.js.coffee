$(document).on 'show.bs.modal',
  '#news-search-options-modal',
  window.usasearch.collapseNavAndFilterDropdowns

focusOnSinceDate = ->
  $('#news-search-options-form-since-date').focus()

$(document).on 'shown.bs.modal',
  '#news-search-options-modal',
  focusOnSinceDate
