$(document).on 'show.bs.modal',
  '#custom-date-search-form-modal',
  window.usasearch.collapseNavAndFilterDropdowns

focusOnSinceDate = ->
  $('#custom-date-search-form-since-date').focus()

$(document).on 'shown.bs.modal',
  '#custom-date-search-form-modal',
  focusOnSinceDate
