generateFullHtmlDocument = (targetId, content) ->
  docType = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
  docPrefix = "<head><title>#{targetId}</title></head>\n<body>\n<div id='container'>\n";
  docSuffix = "</div>\n</body>\n</html>";
  "#{docType}\n#{docPrefix}<div id='#{targetId}'>\n#{content}\n</div>\n#{docSuffix}"


validateDisplayHtml = (sourceSelector, targetId) ->
  val = $(sourceSelector).val();
  htmlDoc = generateFullHtmlDocument targetId, val
  $('#content').val htmlDoc
  $('#validator-form').submit();

$(document).on 'click', '#validate-header, #validate-footer', (e) ->
  e.preventDefault();
  sourceSelector = $(this).data('sourceSelector')
  targetId = sourceSelector.split('_').pop()
  validateDisplayHtml sourceSelector, targetId
