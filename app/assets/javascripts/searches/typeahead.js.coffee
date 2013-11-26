queryFieldSelector = '#search-bar #query.typeahead-enabled'

showSearchButton = () ->
  $('#clear-button').fadeOut()
  $('#search-button').fadeIn()

showClearButton = () ->
  $('#search-button').fadeOut()
  $('#clear-button').fadeIn()

clearQuery = (e) ->
  e.preventDefault()
  e.stopPropagation()
  $queryFieldSelector = $(queryFieldSelector)
  $queryFieldSelector.typeahead 'setQuery', ''
  showSearchButton()
  $queryFieldSelector.focus()

$(document).on 'click', '#clear-button', clearQuery

showCurrentResults = () ->
  showSearchButton()
  $this = $(this)
  $this.fadeOut().off 'click'

whenFocusOnQuery = (e) ->
  $backdrop = $('#typeahead-backdrop')

  unless $backdrop.hasClass 'shown'
    $backdrop.addClass('shown').fadeIn().on 'click', showCurrentResults

  if e.currentTarget.value.length > 0
    showClearButton()
  else
    showSearchButton()

$(document).on 'keyup', queryFieldSelector, whenFocusOnQuery
$(document).on 'typeahead:opened', queryFieldSelector, whenFocusOnQuery


whenSelected = () ->
  $('#search-bar').submit()

$(document).on 'typeahead:selected', queryFieldSelector, whenSelected

ready = () ->
  siteHandle = encodeURIComponent $('#search-bar #affiliate').val();
  $(queryFieldSelector).typeahead
    remote: "/sayt?name=#{siteHandle}&q=%QUERY",
    minLength: 2

$(document).ready ready
$(document).on 'page:load', ready
