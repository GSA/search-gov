toggleMenu = ->
  $('body').toggleClass 'show-menu'
  $('#main-menu').toggleClass 'collapse'

  if menuShown()
    $(document).on 'click.menuWrapper',
      '.show-menu #main-menu-backdrop',
      clickOnBackdrop
  else
    $(document).off 'click.menuWrapper'

menuShown = ->
  $('body').hasClass 'show-menu'

hideMenu = ->
  toggleMenu() if menuShown()

window.usasearch = {} unless window.usasearch?

window.usasearch.toggleMenu ?= toggleMenu

window.usasearch.hideMenu ?= hideMenu

$(document).on 'click.menuButton', '#menu-button', toggleMenu

focusMenuButton = ->
  if menuShown()
    toggleMenu()
    $('#menu-button').focus()

$(document).on 'focus.menuButton', '#menu-button', focusMenuButton

clickOnBackdrop = (e) ->
  e.stopPropagation()
  hideMenu()