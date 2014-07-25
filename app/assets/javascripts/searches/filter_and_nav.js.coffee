onFocusCollapseDropdown = (e) ->
  e.stopPropagation()
  $(this).siblings('.dropdown').addClass 'collapsed'
  $("#{e.data.cousinSelector} .dropdown").addClass 'collapsed'

$(document).on 'focus.usasearch.filter',
  '#search-filters .nav > li',
  cousinSelector: '#search-nav',
  onFocusCollapseDropdown

$(document).on 'focus.usasearch.nav',
  '#search-nav .nav > li',
  cousinSelector: '#search-filters',
  onFocusCollapseDropdown
