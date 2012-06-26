var link = document.createElement("link");
link.type = "text/css";
link.href = document.location.protocol + "//" + document.location.host + "/stylesheets/compiled/sayt.css";
link.rel = "stylesheet";
link.media = "screen";
document.getElementsByTagName("head")[0].appendChild(link);

var script = document.createElement("script");
script.type = "text/javascript";
script.src = document.location.protocol + "//" + document.location.host + "/javascripts/sayt/all.js";
document.getElementsByTagName("head")[0].appendChild(script);
