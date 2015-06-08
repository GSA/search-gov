UserVoice.push ['set', {
  accent_color: '#0066cc',
  autofocus: true,
  mode: 'feedback',
  trigger_color: 'white',
}]

hideWidget = ->
  UserVoice.push ['hide', { target: '#send-an-idea-trigger'}]
  $('html').off 'click.uservoice'

showWidget = (e) ->
  e.preventDefault()

  pageData = $('body').data()
  return if $.isEmptyObject pageData

  showWidgetData = {
    email: pageData['userEmail'],
    id: pageData['userId'],
    name: pageData['userContactName'],
    position: 'bottom-left',
    target: '#send-an-idea-trigger'
  }
  UserVoice.push ['show', showWidgetData]

  $('html').on 'click.uservoice', hideWidget

$(document).on 'click', '#send-an-idea-trigger', showWidget
