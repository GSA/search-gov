trackClick = (e) ->
  e.stopPropagation()
  $link = $(e.currentTarget)
  data = $.extend {},
    $('#search').data(),
    $link.data('click'),
    { u: this.href }
  jQuery.ajax '/clicked', async: false, data: data

$(document).on 'click', '#search .result a, #search #related-searches a', trackClick

visitLink = ($link) ->
  href = $link.attr 'href'
  window.location.href = href

onResultClick = (e) ->
  $target = $(e.target)

  if $target.hasClass 'result'
    $result = $target
  else
    $result = $target.parents('.result')

  $link = $result.find('a')
  $link.trigger 'click'
  visitLink $link

$(document).on 'click', '#search .result', onResultClick
