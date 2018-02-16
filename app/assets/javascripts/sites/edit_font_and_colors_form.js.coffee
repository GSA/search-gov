isShowBoxShadow = () ->
  $('#site_css_property_hash_show_content_box_shadow').prop 'checked'

setBoxShadow = (selector, shadow) ->
  $selector = $(selector)
  $selector.css '-webkit-box-shadow', shadow
  $selector.css '-moz-box-shadow', shadow
  $selector.css 'box-shadow', shadow

changeBoxShadow = (e) ->
  $this = $(e.target)
  targetSelector = $this.attr 'data-target-selector'

  if isShowBoxShadow()
    shadow = "0 0 5px #{e.color.toHex()}"
  else
    shadow = '0 0 0'

  setBoxShadow targetSelector, shadow

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
  contentSelector = '#legacy-preview-font-colors .serp-content'
  if isShowBoxShadow() and isValidColor(color)
    setBoxShadow contentSelector, "0 0 5px #{color}"
  else if !isShowBoxShadow()
    setBoxShadow contentSelector, '0 0 0'

$(document).on 'change', '#site_css_property_hash_show_content_box_shadow', showOrHideBoxShadow

