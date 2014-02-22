ready = ->
  formIds = [
    '#password-reset-form',
    '#user-form',
    '#user-session-form']
  selectors = ("#{formId} > input, #{formId} > .field_with_errors > input" for formId in formIds)
  $(selectors.join()).placeholder();

$(document).ready ready
