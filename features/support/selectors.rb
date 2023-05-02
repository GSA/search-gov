# These should eventually be consolidated with those in
# features/step_definitions/within_steps.rb

module HtmlSelectorsHelpers
  # Maps a name to a selector. Used primarily by the
  #
  #   When /^(.+) within (.+)$/ do |step, scope|
  #
  # step definitions in web_steps.rb
  #
  ORDINAL = {
    'first' => 1,
    'second' => 2,
    'third' => 3
  }.freeze

  def selector_for(locator)
    case locator

    when /the page/
      'html > body'
    when /the Collection URL Prefixes modal/
      '#url-prefixes .modal-body .url-prefixes'
    when /the RSS URLs modal/
      '#urls .modal-body .urls'
    when /the RSS URL last crawl status error message/
      '.urls .error .last-crawl-status.in'
    when /the Supplemental URL last crawl status error message/
      '#indexed-documents .error .last-crawl-status.in'
    when /the Header & Footer form/
      '#edit-header-and-footer'
    when /the Admin Center content/
      '.l-content'
    when /the Admin Center main navigation list/
      '.l-site-nav.main'
    when /the first scaffold row/
      '.records > tr:first-child'
    when /the first table body row/
      'table tbody tr:first-child'
    when /the first table body error row/
      'table tbody tr.error'
    when /the first table body warning row/
      'table tbody tr.warning'
    when /the first table body success row/
      'table tbody tr.success'
    when /the (.*) subsection row/
      "li.sub-section:nth-child(#{ORDINAL[::Regexp.last_match(1)]})"
    when /the search box/
      '#search-bar'
    when /the SERP active navigation/
      '#search-nav .active'
    when /the SERP navigation/
      '#search-nav'
    when /the current time filter/
      '#time-filter-dropdown .current-filter'
    when /the current sort by filter/
      '#sort-filter-dropdown .current-filter'
    when /the custom date search form/
      '#custom-date-search-form'
    when /the med topic govbox/
      '#med-topic'
    when /the news govbox/
      '#news'
    when /the search all sites row/
      '#search .search-all-sites'
    when /the main menu/
      '#main-menu'
    when /the footer/
      '#footer-wrapper'
    when /form tooltip/
      '.form .tooltip'

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #  when /the (notice|error|info) flash/
    #    ".flash.#{$1}"

    # You can also return an array to use a different selector
    # type, like:
    #
    #  when /the header/
    #    [:xpath, "//header"]

    # This allows you to provide a quoted selector as the scope
    # for "within" steps as was previously the default for the
    # web steps:
    when /"(.+)"/
      ::Regexp.last_match(1)

    else
      raise "Can't find mapping from \"#{locator}\" to a selector.\n" \
            "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelpers)
