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
  if $('html[lang=es]').length > 0
    if count > 1
      message = "#{count} sugerencias disponibles. Use la tecla con la flecha ascendente o descendente para seleccionar una de ellas. Presione \"enter\" para hacer la búsqueda de su selección."
    else
      message = "#{count} sugerencia disponible. Use la tecla con la flecha ascendente o descendente para seleccionarla. Presione \"enter\" para hacer la búsqueda de la selección sugerida."
  else
    if count > 1
      message = "#{count} suggestions are available. Use the up and down arrow keys to select to one. Press enter to search on your selected suggestion."
    else
      message = '1 suggestion is available. Use the up and down arrow keys to select to it. Press enter to search on your selected suggestion.'

  return message


updateStatus = ->
  $ttStatus = $('#tt-status')
  currentCount = $ttStatus.data('suggestionCount')
  suggestionCount = $('.tt-dataset .tt-suggestion').length
  return if currentCount == suggestionCount

  $ttStatus.data 'suggestionCount', suggestionCount
  return if suggestionCount == 0

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

whenClosed = ->
  $('#tt-status').data 'suggestionCount', 0

$(document).on 'focus keydown', queryFieldSelector, whenFocusOnQuery
$(document).on 'typeahead:open', queryFieldSelectorWithTypeahead, whenOpened
$(document).on 'typeahead:close', queryFieldSelectorWithTypeahead, whenClosed
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
  siteHandle = encodeURIComponent $('#search-bar #affiliate').val()
  bloodhound = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.whitespace
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: "/sayt?name=#{siteHandle}&q=%QUERY"
      wildcard: "%QUERY"

  $(queryFieldSelectorWithTypeahead).typeahead
    minLength: 2
  ,
    source: bloodhound
    limit: 1000 # overcomes a typeahead bug that truncates suggestions - server limits results to 5 already
    templates:
      suggestion: (data) ->
        typedQuery = $(queryFieldSelectorWithTypeahead).val()
        if data.indexOf(typedQuery) == -1 # if the typedQuery is not in the suggestion (i.e. it's misspelled)
          "<div><strong>#{data}</strong></div>"
        else
          suggestionSuffix = data.substr(typedQuery.length)
          "<div>#{typedQuery}<strong>#{suggestionSuffix}</strong></div>"

$(document).ready ready
$(document).on 'page:load', ready
