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

buildStatusMessage = (count) ->
  if $('html[lang=es]').length > 1
    if count > 1
      message = "Hay #{count} sugerencias disponibles. Use la tecla con la flecha ascendente o descendente para seleccionar la que desee. Presione \"enter\" para hacer la búsqueda de su selección."
    else
      message = 'Hay 1 sugerencia disponible. Use la flecha ascendente o descendente para seleccionarla. Presione "enter" para hacer la búsqueda de la selección sugerida.'
  else
    if count > 1
      message = "#{count} suggestions are available. Use the up and down arrow keys to select to one. Press enter to search on your selected suggestion."
    else
      message = '1 suggestion is available. Use the up and down arrow keys to select to it. Press enter to search on your selected suggestion.'

  return message


updateStatus = ->
  $ttStatus = $('#tt-status')
  currentCount = $ttStatus.data('suggestionCount')
  suggestionCount = $('.tt-suggestions .tt-suggestion').length
  return if currentCount == suggestionCount

  $ttStatus.data 'suggestionCount', suggestionCount
  message = buildStatusMessage suggestionCount
  $ttStatus.html message

updateStatusWithTimeout = ->
  setTimeout updateStatus, 500

whenFocusOnQuery = (e) ->
  return if e.which? and e.which == 13
  e.stopPropagation()
  window.usasearch.collapseNavAndFilterDropdowns()
  window.usasearch.hideMenu()
  showOrHideClearButton()

whenOpened = (e) ->
  whenFocusOnQuery e
  updateStatusWithTimeout()

whenClosed = (e) ->
  $('#tt-status').data 'suggestionCount', 0

$(document).on 'focus keydown', queryFieldSelector, whenFocusOnQuery
$(document).on 'typeahead:opened', queryFieldSelectorWithTypeahead, whenOpened
$(document).on 'typeahead:closed', queryFieldSelectorWithTypeahead, whenClosed
$(document).on 'keyup', queryFieldSelectorWithTypeahead, updateStatusWithTimeout


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
