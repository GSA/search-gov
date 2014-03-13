collapseDropdown = ->
  $target = $(this)
  unless $target.hasClass('active') and $target.hasClass('active dropdown')
    $target.siblings('.dropdown').addClass 'collapsed'

$(document).on 'focus', '#nav > .nav > li', collapseDropdown
