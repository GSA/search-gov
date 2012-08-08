var usasearch = {};

if ((typeof usasearch_config === 'object') && (usasearch_config.constructor == Object)) {
  usasearch.config = usasearch_config;
} else {
  usasearch.config = {};
}

if (usasearch.config.host === undefined) {
  usasearch.config.host = ("https:" == document.location.protocol ? "https:" : "http:") + "//search.usa.gov";
}

/*
 Developed by Robert Nyman, http://www.robertnyman.com
 Code/licensing: http://code.google.com/p/getelementsbyclassname/
 */
var getElementsByClassName = function (className, tag, elm){
  if (document.getElementsByClassName) {
    getElementsByClassName = function (className, tag, elm) {
      elm = elm || document;
      var elements = elm.getElementsByClassName(className),
          nodeName = (tag)? new RegExp("\\b" + tag + "\\b", "i") : null,
          returnElements = [],
          current;
      for(var i=0, il=elements.length; i<il; i+=1){
        current = elements[i];
        if(!nodeName || nodeName.test(current.nodeName)) {
          returnElements.push(current);
        }
      }
      return returnElements;
    };
  }
  else if (document.evaluate) {
    getElementsByClassName = function (className, tag, elm) {
      tag = tag || "*";
      elm = elm || document;
      var classes = className.split(" "),
          classesToCheck = "",
          xhtmlNamespace = "http://www.w3.org/1999/xhtml",
          namespaceResolver = (document.documentElement.namespaceURI === xhtmlNamespace)? xhtmlNamespace : null,
          returnElements = [],
          elements,
          node;
      for(var j=0, jl=classes.length; j<jl; j+=1){
        classesToCheck += "[contains(concat(' ', @class, ' '), ' " + classes[j] + " ')]";
      }
      try	{
        elements = document.evaluate(".//" + tag + classesToCheck, elm, namespaceResolver, 0, null);
      }
      catch (e) {
        elements = document.evaluate(".//" + tag + classesToCheck, elm, null, 0, null);
      }
      while ((node = elements.iterateNext())) {
        returnElements.push(node);
      }
      return returnElements;
    };
  }
  else {
    getElementsByClassName = function (className, tag, elm) {
      tag = tag || "*";
      elm = elm || document;
      var classes = className.split(" "),
          classesToCheck = [],
          elements = (tag === "*" && elm.all)? elm.all : elm.getElementsByTagName(tag),
          current,
          returnElements = [],
          match;
      for(var k=0, kl=classes.length; k<kl; k+=1){
        classesToCheck.push(new RegExp("(^|\\s)" + classes[k] + "(\\s|$)"));
      }
      for(var l=0, ll=elements.length; l<ll; l+=1){
        current = elements[l];
        match = false;
        for(var m=0, ml=classesToCheck.length; m<ml; m+=1){
          match = classesToCheck[m].test(current.className);
          if (!match) {
            break;
          }
        }
        if (match) {
          returnElements.push(current);
        }
      }
      return returnElements;
    };
  }
  return getElementsByClassName(className, tag, elm);
};

if (getElementsByClassName('usagov-search-autocomplete').length > 0) {
  var link = document.createElement("link");
  link.type = "text/css";
  link.href = usasearch.config.host + "/stylesheets/compiled/sayt/custom.css";
  link.rel = "stylesheet";
  link.media = "screen";
  document.getElementsByTagName("head")[0].appendChild(link);

  var script = document.createElement("script");
  script.type = "text/javascript";
  script.src = usasearch.config.host + "/javascripts/sayt/all.js";
  document.getElementsByTagName("head")[0].appendChild(script);
}

if (usasearch.config.siteHandle) {
  if (usasearch.config.enableDiscoveryTag === undefined) {
    usasearch.config.enableDiscoveryTag = true;
  }

  if (usasearch.config.enableDiscoveryTag) {
    var aid = usasearch.config.siteHandle;
    var discoveryScript = document.createElement("script");
    discoveryScript.type = "text/javascript";
    discoveryScript.src = usasearch.config.host + "/javascripts/stats.js";
    document.getElementsByTagName("head")[0].appendChild(discoveryScript);
  }
}
