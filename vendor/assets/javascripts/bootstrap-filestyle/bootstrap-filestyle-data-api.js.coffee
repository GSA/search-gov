ready = () ->
  notIE7 = 'postMessage' of window;
  return unless notIE7
  $('[data-provide="filestyle"]').each () ->
    $this = $(this)
    options =
      buttonText: $this.attr('data-buttonText')
      input: `$this.attr('data-input') === 'false' ? false : true`
      icon: `$this.attr('data-icon') === 'false' ? false : true`,
      classButton: $this.attr('data-classButton'),
      classInput: $this.attr('data-classInput'),
      classIcon: $this.attr('data-classIcon')

    $this.filestyle options

$(document).ready ready
$(document).on 'page:load', ready
