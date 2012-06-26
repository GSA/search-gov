if (usasearch_host === undefined) {
  var usasearch_host = "http://search.usa.gov";
}

var link = document.createElement("link");
link.type = "text/css";
link.href = usasearch_host + "/stylesheets/compiled/sayt.css";
link.rel = "stylesheet";
link.media = "screen";
document.getElementsByTagName("head")[0].appendChild(link);

var script = document.createElement("script");
script.type = "text/javascript";
script.src = usasearch_host + "/javascripts/sayt/all.js";
document.getElementsByTagName("head")[0].appendChild(script);
