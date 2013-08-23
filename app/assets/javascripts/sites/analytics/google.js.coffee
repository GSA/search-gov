`
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-31302465-4', 'usa.gov');
  ga('send', 'pageview');
`

$(document).on 'page:change', () ->
  ga 'create', 'UA-31302465-4', 'usa.gov'
  page = window.location.pathname + window.location.search
  ga 'send', 'pageview', { 'page': page }

trackViewModal = () ->
  page = $(this).data 'url'
  page ?= $(this).attr 'href'
  ga 'send', 'pageview', { 'page': page, 'title': 'viewModal', }

$(document).on 'click', '.help-link, #preview-trigger', trackViewModal
