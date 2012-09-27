jQuery(document).ready(function() {
  jQuery.infinitescroll.prototype._showdonemsg_usasearch = function() {

    var opts = this.options;
    opts.loading.msg
        .find('img')
        .hide()
        .parent()
        .find('div').html(opts.loading.finishedMsg).css('text-align', 'center').animate({ opacity: 1 }, 1000);

    // user provided callback when done
    opts.errorCallback.call($(opts.contentSelector)[0], 'done');
  };

  jQuery.infinitescroll.prototype._determinepath_usasearch = function(path) {
    var opts = this.options;
    if (path.match(/^(.*?page=)\d+(.*?|$)/)) {
      path = path.match(/^(.*?page=)\d+(.*|$)/).slice(1);
    }
    return path;
  };

  jQuery.infinitescroll.prototype._loadcallback_usasearch = function(box, responseText) {

    var opts = this.options,
        callback = this.options.callback, // GLOBAL OBJECT FOR CALLBACK
        result = (opts.state.isDone) ? 'done' : (!opts.appendCallback) ? 'no-append' : 'append',
        frag,
        odieFrag,
        logos = ['bing', 'usasearch'],
        logo,
        currentLogo,
        odieDocs;

    switch (result) {

      case 'done':

        this._showdonemsg();
        return false;

        break;

      case 'append':

        var children = box.children();

        if (children.length == 0) {
          return this._error('end');
        } else {
          var totalRegex = /(\d+,?\d+)+\s+(results|resultados)$/;
          var updatedTotal = $('#summary', responseText).text().match(totalRegex).slice(0, 1);
          var currentTotal = $('#summary').text().match(totalRegex).slice(0, 1);
          $('#summary').text($('#summary').text().replace(new RegExp(currentTotal), updatedTotal));
        }

        $(logos).each(function() {
          logo = this;
          if (box.children('.results-by-logo').hasClass(logo)) {
            currentLogo = logo;
            $('#results .pagination-and-logo').each(function() {
              if ($(this).children().hasClass(logo))
                $(this).remove();
            });
          }
        });
        box.children('.results-by-logo').wrap('<div class="pagination-and-logo" />');
        if (currentLogo == 'usasearch') {
          box.children('.searchresult').addClass('indexeddocresult');
          if ((currentLogo == 'usasearch') && ($('#indexed_documents').length == 0)) {
            box.children('.searchresult').wrapAll('<div id="indexed_documents" />');
          }
        }

        frag = document.createDocumentFragment();
        while (box[0].firstChild) {
          frag.appendChild(box[0].firstChild);
        }

        if (currentLogo == 'usasearch') {
          if ($('#results #indexed_documents').length == 0) {
            odieFrag = document.createDocumentFragment();
            var govbox = document.createElement('div');
            govbox.className = 'govbox';
            var wrappers = ['govbox-wrapper-top', 'govbox-wrapper-middle', 'govbox-wrapper-bottom'];
            for (var i = 0; i < wrappers.length; i++) {
              var wrapperElement = document.createElement('div');
              wrapperElement.className = wrappers[i];
              if (i == 1) {
                wrapperElement.appendChild(frag);
              }
              govbox.appendChild(wrapperElement);
            }
            odieFrag.appendChild(govbox);
            $(opts.contentSelector)[0].appendChild(odieFrag);
          } else {
            $('#results #indexed_documents')[0].appendChild(frag);
          }
        } else {
          $(opts.contentSelector)[0].appendChild(frag);
        }

        data = children.get();
        break;
    }

    opts.loading.finished.call($(opts.contentSelector)[0],opts)

    // smooth scroll to ease in the new content
    if (opts.animate) {
      var scrollTo = $(window).scrollTop() + $('#infscr-loading').height() + opts.extraScrollPx + 'px';
      $('html,body').animate({ scrollTop:scrollTo }, 800, function () {
        opts.state.isDuringAjax = false;
      });
    }

    if (!opts.animate) opts.state.isDuringAjax = false; // once the call is done, we can allow it again.

    callback(this,data);
  };

  function finishedMessage() {
    var backToTop = jQuery('body.es').length == 1 ? 'Volver al inicio' : 'Back to top';
    return '<a href="#main_content">'.concat(backToTop, '</a>');
  }

  jQuery('#results').infinitescroll( {
    navSelector: '#usasearch_pagination',
    nextSelector: '#usasearch_pagination a.next_page',
    itemSelector: '#results .searchresult, .results-by-logo',
    loading: {
      img: '/images/infinite_scroll/ajax_loader.gif',
      msgText: '',
      finishedMsg: finishedMessage()
    },
    state: {
      currPage: jQuery('#usasearch_pagination .current').text()
    },
    bufferPx: 500,
    behavior: 'usasearch'
  });

  if ((jQuery('#usasearch_pagination').length > 0) && (jQuery('#results .searchresult').length < 10)) {
    jQuery('#results').infinitescroll('scroll');
  }
});
