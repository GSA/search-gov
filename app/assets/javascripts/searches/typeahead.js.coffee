queryFieldSelector = '#search-bar #query'
queryFieldSelectorWithTypeahead = '#search-bar #query.typeahead-enabled'

clearQuery = ->
  $queryFieldSelector = $(queryFieldSelector)

  if $queryFieldSelector.hasClass 'typeahead-enabled'
    $queryFieldSelector.typeahead('setQuery', '')
  else
    $queryFieldSelector.val('')

  $queryFieldSelector.focus()
  $('#search-bar').removeClass 'has-query-term'

showOrHideClearButton = ->
  if $(queryFieldSelector).val().length > 0
    $('#search-bar').addClass 'has-query-term'
  else
    $('#search-bar').removeClass 'has-query-term'

whenFocusOnQuery = (e) ->
  return if e.which? and e.which == 13
  e.stopPropagation()
  window.usasearch.collapseNavAndFilterDropdowns()
  window.usasearch.hideMenu()
  showOrHideClearButton()

$(document).on 'focus keydown', queryFieldSelector, whenFocusOnQuery
$(document).on 'typeahead:opened', queryFieldSelectorWithTypeahead, whenFocusOnQuery

submitForm = (e) ->
  #  submit form when pressing enter on IE8
  if e.which? and e.which == 13
    e.preventDefault()
    $('#search-bar').submit()

$(document).on 'keypress', queryFieldSelector, submitForm

clearQueryEvent = (e) ->
  e.preventDefault()
  e.stopPropagation()
  clearQuery()

$(document).on 'click.clear-button', '#clear-button', clearQueryEvent

clearQueryOnKeypressEvent = (e) ->
  e.preventDefault()
  e.stopPropagation()
  if e.which == 13
    clearQuery e

$(document).on 'keypress.clear-button', '#clear-button', clearQueryOnKeypressEvent

whenSelected = () ->
  $('#search-bar').submit()

$(document).on 'typeahead:selected', queryFieldSelectorWithTypeahead, whenSelected

ready = () ->
  siteHandle = encodeURIComponent $('#search-bar #affiliate').val();
  $(queryFieldSelectorWithTypeahead).typeahead
    remote: "/sayt?name=#{siteHandle}&q=%QUERY",
    minLength: 2

$(document).ready ready
$(document).on 'page:load', ready
