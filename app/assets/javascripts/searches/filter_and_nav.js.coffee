onFocusCollapseDropdown = (e) ->
  $(this).siblings('.dropdown').addClass 'collapsed'
  $("#{e.data.cousinSelector} .dropdown").addClass 'collapsed'

$(document).on 'click.usasearch.filter focus.usasearch.filter',
  '#search-filters-and-results-count .nav > li',
  cousinSelector: '#search-nav',
  onFocusCollapseDropdown

$(document).on 'click.usasearch.nav focus.usasearch.nav',
  '#search-nav .nav > li',
  cousinSelector: '#search-filters-and-results-count',
  onFocusCollapseDropdown

window.usasearch = {} unless window.usasearch?

collapseNavAndFilterDropdowns = ->
  $('#search-filters-and-results-count .dropdown, #search-nav .dropdown').addClass 'collapsed'

window.usasearch.collapseNavAndFilterDropdowns ?= collapseNavAndFilterDropdowns

$(document).on 'focus.usasearch.main-content',
  '#main-content',
  collapseNavAndFilterDropdowns
