focusOnMainContent = (e) ->
  e.stopPropagation()
  targetId =   $(e.currentTarget).attr('href')
  $(targetId).focus()

$(document).on 'click', '#skiplink', focusOnMainContent
