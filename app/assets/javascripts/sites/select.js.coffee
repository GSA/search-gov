ready = ->
  $('#site_select').select2
    dropdownAutoWidth: true,
    placeholder: 'Select a site'

$(document).ready(ready)
$(document).on 'page:load', ready
$(document).on 'change', '#site_select', (e) ->
  Turbolinks.visit '/sites/' + e.val
