collapseDropdown = ->
  $target = $(this)
  unless $target.hasClass('active') and $target.hasClass('active dropdown')
    $target.siblings('.dropdown').addClass 'collapsed'
  $mainMenu = $('#main-menu')
  $mainMenu.removeClass('in').addClass('collapse') if $mainMenu.hasClass('in')

$(document).on 'focus', '#search-nav > .nav > li', collapseDropdown
