{
  'in the main navigation bar': '#main_nav',
  'in the breadcrumbs': '.breadcrumbs',
  'in the page header': 'h1',
  'in the user menu': '.user-menu',
  'in the search navbar': '#search-nav',
  'in the boosted contents section': '#best-bets',
  'in the Super Admin page': '.container',
  'in the twitter govbox': '#tweets',
  'in the site header': '.l-site-header',
  'in the active site main navigation': '.l-site-nav.main .active',
  'in the active site sub navigation': '.l-site-nav.sub .active',
  'in the SearchgovDomain URLs table': '#as_admin__searchgov_urls-active-scaffold',
  'in the SearchgovDomain Sitemaps table': '#as_admin__sitemaps-active-scaffold'
}.
  each do |suffix, selector|
    Then /^(.+) #{Regexp.escape(suffix)}$/ do |step_string|
      within(selector) do
        step step_string
      end
    end
  end
