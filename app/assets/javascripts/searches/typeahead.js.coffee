queryFieldSelector = '#search-bar #query'
queryFieldSelectorWithTypeahead = '#search-bar #query.typeahead-enabled'

clearQuery = (e) ->
  e.preventDefault()
  e.stopPropagation()
  $queryFieldSelector = $(queryFieldSelector)

  if $queryFieldSelector.hasClass 'typeahead-enabled'
    $queryFieldSelector.typeahead('setQuery', '')
  else
    $queryFieldSelector.val('')

  $queryFieldSelector.focus()
  $('#search-bar').removeClass 'has-query-term'

$(document).on 'click', '#clear-button', clearQuery

showCurrentResults = () ->
  $this = $(this)
  $this.removeClass('shown').fadeOut().off 'click'

whenFocusOnQuery = (e) ->
  $backdrop = $('#typeahead-backdrop')

  unless $backdrop.hasClass 'shown'
    $backdrop.addClass('shown').fadeIn().on 'click', showCurrentResults

  if e.currentTarget.value.length > 0
    $('#search-bar').addClass 'has-query-term'
  else
    $('#search-bar').removeClass 'has-query-term'

#  submit form when pressing enter on IE8
  if e.which? and e.which == 13
    e.preventDefault()
    $('#search-bar').submit()

$(document).on 'keyup', queryFieldSelector, whenFocusOnQuery
$(document).on 'typeahead:opened', queryFieldSelectorWithTypeahead, whenFocusOnQuery


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
