collapseFilterDropdown = ->
  $('#search-filters .dropdown').addClass 'collapsed'

$(document).on 'show.bs.modal',
  '#news-search-options-modal',
  collapseFilterDropdown

focusOnSinceDate = ->
  $('#news-search-options-form-since-date').focus()

$(document).on 'shown.bs.modal',
  '#news-search-options-modal',
  focusOnSinceDate
