{
  'in the logo' => '#top_logo',
  'in the header' => '.header',
  'in the affiliate program dropdown menu' => '.affiliate-li',
  'in the api dropdown menu' => '.api-li',
  'in the main navigation bar' => '#main_nav',
  'in the site navigation bar' => '.affiliate-left-nav',
  'in the breadcrumbs' => '.breadcrumbs',
  'in the page header' => 'h1',
  'in the mobile page header' => 'h1.page-title',
  'in the connect section' => '.connect',
  'in the footer' => '.footer',
  'in the query search results table header' => '.query_search_results_table_header',
  'in the callout boxes' => '.col-2',
  'in the side note boxes' => '.column-2',
  'in the search navigation' => '#main_nav',
  'in the homepage header' => '.header',
  'in the homepage footer' => '.footer',
  'in the homepage about section' => '.about',
  'in the homepage tagline' => '.tagline',
  'in the left column' => '#left_column',
  'in the selected vertical navigation' => '#sidebar span',
  'in the search results section' => '#results',
  'in the results filters' => '#results .results-filters',
  'in the selected time filter' => '#results .time-filters .selected',
  'in the selected sort filter' => '#results .sort-filters .selected',
  'in the no results section' => '.no-results',
  'in the featured collections section' => '.featured-collections',
  'in the document collections section' => '.document-collections',
  'in the pagination' => '.pagination',
  'in the affiliate boosted contents section' => '.boosted-contents',
  'in the boosted contents section' => '#boosted',
  'in the mobile boosted contents section' => '#boostedresults',
  'in the uncrawled URL list' => '.uncrawled-url-list',
  'in the previously crawled URL list' => '.crawled-url-list',
  'in the indexed documents section' => '#indexed_documents',
  'in the medline govbox' => '.medline',
  'in the agency govbox' => '.agency',
  'in the SERP header' => '#header',
  'in the SERP footer' => '#footer',
  'in the page content' => '.content',
  'in the API TOS section' => '.api.tos',
  'in the registration form' => 'form#new_user',
  'in the rss feed govbox' => '#news_items_govbox',
  'in the video rss feed govbox' => '#video_news_items_govbox',
  'in the active scaffold header' => 'h2',
  'in the contributor facet selector' => '#facet_contributor',
  'in the subject facet selector' => '#facet_subject',
  'in the publisher facet selector' => '#facet_publisher',
  'in the selected contributor facet selector' => '#facet_contributor .selected',
  'in the selected subject facet selector' => '#facet_subject .selected',
  'in the selected publisher facet selector' => '#facet_publisher .selected',
  'in the Super Admin page' => '.container',
  'in the form govbox' => '#form_govbox',
  'in the form govbox description' => '#form_govbox .description',
  'in the social media list' => '#social_media_profiles',
  'in the search box' => '#search_box'
}.
  each do |within, selector|
    Then /^(.+) #{within}$/ do |step_string|
      within(selector) do
        step step_string
      end
    end
  end

{
  'in the new user form' => '#new_user',
  'in the login form' => '#new_user_session'
}.
  each do |within, selector|
    When /^I fill in the following #{within}:$/ do |fields|
      within(selector) do
        fields.rows_hash.each do |name, value|
          step %{I fill in "#{name}" with "#{value}"}
        end
      end
    end
  end
