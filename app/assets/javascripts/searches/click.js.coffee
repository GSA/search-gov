trackClick = (e) ->
  e.stopPropagation()
  $link = $(e.currentTarget)
  data = $.extend {},
    $('#search').data(),
    { u: this.href },
    $link.data('click')
  jQuery.ajax '/clicked', async: false, data: data

$(document).on 'click', '#search .result a, #search #related-searches a', trackClick
$(document).on 'click.tweet', '#tweets .profile, #tweets .text a, #tweets .timestamp a', trackClick

visitLink = (link) ->
  window.location.href = link.href if link?

onResultClick = (e) ->
  $target = $(e.target)

  if $target.hasClass 'result'
    $result = $target
  else
    $result = $target.parents('.result')

  $link = $result.find('h3 a').trigger('click')
  visitLink $link[0]

$(document).on 'click', '#search .result', onResultClick
