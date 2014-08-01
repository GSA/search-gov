onFocusCollapseDropdown = (e) ->
  $(this).siblings('.dropdown').addClass 'collapsed'
  $("#{e.data.cousinSelector} .dropdown").addClass 'collapsed'

$(document).on 'click.usasearch.filter focus.usasearch.filter',
  '#search-filters .nav > li',
  cousinSelector: '#search-nav',
  onFocusCollapseDropdown

$(document).on 'click.usasearch.nav focus.usasearch.nav',
  '#search-nav .nav > li',
  cousinSelector: '#search-filters',
  onFocusCollapseDropdown

window.usasearch = {} unless window.usasearch?

collapseNavAndFilterDropdowns = ->
  $('#search-filters .dropdown, #search-nav .dropdown').addClass 'collapsed'

window.usasearch.collapseNavAndFilterDropdowns ?= collapseNavAndFilterDropdowns
