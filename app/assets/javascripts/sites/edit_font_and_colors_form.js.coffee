isShowBoxShadow = () ->
  $('#site_css_property_hash_show_content_box_shadow').prop 'checked'

changeBoxShadow = (e) ->
  $this = $(e.target)
  $targetSelector = $($this.attr 'data-target-selector')

  if isShowBoxShadow()
    shadow = "0 0 5px #{e.color.toHex()}"
  else
    shadow = '0 0 0'

  $targetSelector.css '-webkit-box-shadow', shadow
  $targetSelector.css '-moz-box-shadow', shadow
  $targetSelector.css 'box-shadow', shadow

changeColor = (e) ->
  $this = $(this)
  $colorInputField = $this.find('input[type="text"]')[0]
  if $colorInputField.id == 'site_css_property_hash_content_box_shadow_color'
    changeBoxShadow e
    return
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
      title: 'Select Custom theme to modify'

ready = () ->
  return unless $('#edit-font-and-colors')[0]?
  if $('#site_theme_custom').prop 'checked'
    enableColorPickers()
  else if $('#site_theme_default').prop 'checked'
    disableColorPickers()

$(document).ready ready
$(document).on 'page:load', ready
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
  changeCssProperty e, $(this).val()

showOrHideContentBorder = (e, isShowContentBorder) ->
  targetSelector = $(e.target).attr 'data-target-selector'
  if isShowContentBorder
    $(targetSelector).addClass 'serp-content-show-border'
  else
    $(targetSelector).removeClass 'serp-content-show-border'

$(document).on 'change', '#site_css_property_hash_show_content_border', (e) ->
  isShowContentBorder = $(this).prop('checked')
  showOrHideContentBorder e, isShowContentBorder

showOrHideBoxShadow = () ->
  $colorInputField = $('#site_css_property_hash_content_box_shadow_color')
  color = $colorInputField.val()
  $colorPicker = $($colorInputField.parents('[data-provide="colorpicker"]')[0])
  if isShowBoxShadow() and isValidColor(color)
    $colorPicker.colorpicker().colorpicker 'setValue', color
  else if !isShowBoxShadow()
    $colorPicker.colorpicker().colorpicker 'setValue', color
  ready

$(document).on 'change', '#site_css_property_hash_show_content_box_shadow', showOrHideBoxShadow

