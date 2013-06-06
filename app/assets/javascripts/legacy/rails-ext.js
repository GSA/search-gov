(function() {
  function handleRemote(element) {
    var method, url, params;

    var event = element.fire("ajax:before");
    if (event.stopped) return false;

    if (element.tagName.toLowerCase() === 'form') {
      method = element.readAttribute('method') || 'post';
      url    = element.readAttribute('action');
      params = element.serialize();
    } else {
      method = element.readAttribute('data-method') || 'get';
      url    = element.readAttribute('href');
      params = {};
    }

    new Ajax.Request(url, {
      method: method,
      parameters: params,
      evalScripts: true,

      onComplete:    function(request) { element.fire("ajax:complete", request); },
      onSuccess:     function(request) { element.fire("ajax:success",  request); },
      onFailure:     function(request) { element.fire("ajax:failure",  request); }
    });

    element.fire("ajax:after");
  }

  document.on("click", "input[data-remote]", function(event, element) {
    if (event.stopped) return;
    handleRemote(element);
    event.stop();
  });
})();