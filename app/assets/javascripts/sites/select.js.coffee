ready = ->
  $('#site_select').select2
    dropdownAutoWidth: true,
    placeholder: 'Select a site'

$(document).on 'turbolinks:load', ready
$(document).on 'select2:select', '#site_select', (e) ->
  Turbolinks.visit '/sites/' + e.params.data.id
