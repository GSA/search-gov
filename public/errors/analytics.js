window.dataLayer = window.dataLayer || [];
dataLayer.push({ "SERP_version": "version_2024" });

(function (w, d, s, l, i) {
  w[l] = w[l] || [];
  w[l].push({ "gtm.start": new Date().getTime(), event: "gtm.js" });
  var f = d.getElementsByTagName(s)[0],
    j = d.createElement(s),
    dl = l != "dataLayer" ? "&l=" + l : "";
  j.async = true;
  j.src = "https://www.googletagmanager.com/gtm.js?id=" + i + dl;
  f.parentNode.insertBefore(j, f);
})(window, document, "script", "dataLayer", "GTM-N56JXGD");

(function () {
  var fa = document.createElement("script");
  fa.id = "_fed_an_ua_tag";
  fa.type = "text/javascript";
  fa.async = true;
  fa.src = "https://dap.digitalgov.gov/Universal-Federated-Analytics-Min.js?agency=GSA";
  document.getElementsByTagName("head")[0].appendChild(fa);
})();
