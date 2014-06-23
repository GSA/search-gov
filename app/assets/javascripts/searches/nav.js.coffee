collapseDropdown = ->
  $target = $(this)
  unless $target.hasClass('active') and $target.hasClass('active dropdown')
    $target.siblings('.dropdown').addClass 'collapsed'
    window.usasearch.hideMenu()

$(document).on 'focus', '#search-nav > .nav > li', collapseDropdown
