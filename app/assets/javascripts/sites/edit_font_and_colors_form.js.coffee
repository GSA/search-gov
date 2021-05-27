changeColor = (e) ->
  $this = $(this)
  $colorInputField = $this.find('input[type="text"]')[0]
  targetSelector = $this.attr 'data-target-selector'
  targetCssProperties = $this.attr('data-target-css-properties').split /,\s+/
  $(targetSelector).css targetCssProperty, e.color.toHex() for targetCssProperty in targetCssProperties

enableColorPickers = () ->
  $('[data-provide="colorpicker"] .add-on-colorpicker').each () ->
    $(this).tooltip 'destroy'

  $('[data-provide="colorpicker"] input').prop 'disabled', false

  $('[data-provide="colorpicker"]').each () ->
    $(this).colorpicker().on 'changeColor', changeColor

disableColorPickers = () ->
  $('[data-provide="colorpicker"]').each () ->
    $this = $(this)
    defaultColor = $this.data 'default-color'
    $this.colorpicker('setValue', defaultColor).colorpicker('destroy')

  $('[data-provide="colorpicker"] input').prop 'disabled', true

  $('[data-provide="colorpicker"] .add-on-colorpicker').each () ->
    $(this).tooltip
      placement: 'right',
      title: 'Select Custom color scheme to modify'

isTheme = (theme) ->
  $("#site_theme_#{theme}").prop 'checked'

ready = () ->
  return unless $('#edit-font-and-colors')[0]?
  if isTheme 'custom'
    enableColorPickers()
  else if isTheme 'default'
    disableColorPickers()

$(document).on 'turbolinks:load', ready
$(document).on 'change', '#site_theme_default, #site_theme_custom', ready

isValidColor = (color) ->
  color.match /^#([0-9A-F]{3}|[0-9A-F]{6})$/i

$(document).on 'change', '[data-provide="colorpicker"] input', () ->
  $this = $(this)
  value = $this.val()
  if isValidColor value
    colorPicker = $this.parents('[data-provide="colorpicker"]')[0]
    $(colorPicker).colorpicker 'setValue', value

changeCssProperty = (e, cssPropertyValue) ->
  $this = $(e.target)
  targetSelector = $this.attr 'data-target-selector'
  targetCssProperties = $this.attr('data-target-css-properties').split /,\s+/
  $(targetSelector).css targetCssProperty, cssPropertyValue for targetCssProperty in targetCssProperties

$(document).on 'change', '#site_css_property_hash_font_family', (e) ->
  fontFamilyName = $(this).val()
  fontFamilyName = $('.font-colors-wrapper').data('defaultFontFamily') if fontFamilyName == 'Default'
  changeCssProperty e, fontFamilyName
