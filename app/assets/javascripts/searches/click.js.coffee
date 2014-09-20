trackClick = (e) ->
  e.stopPropagation()
  $link = $(e.currentTarget)
  data = $.extend {},
    $('#search').data(),
    { u: this.href },
    $link.data('click')
  jQuery.ajax '/clicked', async: false, data: data

$(document).on 'click', '#search a[data-click]', trackClick
