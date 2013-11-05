queryFieldSelector = '#search-bar #query.typeahead-enabled'

whenFocusOnQuery = () ->
  $('.hide-on-sayt-open').hide()

$(document).on 'focusin', queryFieldSelector, whenFocusOnQuery
$(document).on 'typeahead:opened', queryFieldSelector, whenFocusOnQuery

showCurrentResults = () ->
  $('.hide-on-sayt-open').show()

$(document).on 'typeahead:closed', queryFieldSelector, showCurrentResults

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
