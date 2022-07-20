trackClick = (e) ->
  e.stopPropagation()
  $link = $(e.currentTarget)
  data = $.extend {},
    $('#search').data(),
    { url: this.href },
    $link.data('click')
  jQuery.ajax type: 'POST', async: false, url: '/clicked', data: data

$(document).on 'click', '#search a[data-click]', trackClick
