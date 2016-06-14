@vcr
Feature: Blended Search
  In order to get various types of relevant government-related information from specific sites
  As a site visitor
  I want to be able to search for information

  Scenario: Simple search across news and indexed documents
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | gets_blended_results    | is_rss_govbox_enabled |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | true                    | false                 |
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                  | is_navigable |
      | Press         | http://www.whitehouse.gov/feed/press | true         |
      | Blog          | http://www.whitehouse.gov/feed/blog  | true         |
    And feed "Press" has the following news items:
      | link                             | title               | guid       | published_ago | multiplier | description                                | body                 |
      | http://www.whitehouse.gov/news/1 | First <b> item </b> | pressuuid1 | day           | 1          | <i> item </i> First news item for the feed | first news item body |
      | http://www.whitehouse.gov/news/2 | Second item         | pressuuid2 | day           | 1          | item Next news item for the feed           | next news item body  |
      | http://www.whitehouse.gov/news/9 | stale first item    | pressuuid9 | months        | 14         | item first Stale news item                 | stale news item body |
    And feed "Blog" has the following news items:
      | link                             | title       | guid  | published_ago | description                       |
      | http://www.whitehouse.gov/news/3 | Third item  | uuid3 | week          | item More news items for the feed |
      | http://www.whitehouse.gov/news/4 | Fourth item | uuid4 | week          | item Last news item for the feed  |
    And the following IndexedDocuments exist:
      | title                   | description                          | url                                 | affiliate | last_crawl_status | published_ago  |
      | The last hour article   | Within the last hour article on item | http://p.whitehouse.gov/hour.html   | bar.gov   | OK                | 30 minutes ago |
      | The last day article    | Within the last day article on item  | http://p.whitehouse.gov/day.html    | bar.gov   | OK                | 8 hours ago    |
      | The last week article   | Within last week article on item     | http://p.whitehouse.gov/week.html   | bar.gov   | OK                | 3 days ago     |
      | The last month article  | Within last month article on item    | http://p.whitehouse.gov/month.html  | bar.gov   | OK                | 15 days ago    |
      | The last year article   | Within last year article on item     | http://p.whitehouse.gov/year.html   | bar.gov   | OK                | 60 days ago    |
      | The last decade article | Within last decade article on item   | http://p.whitehouse.gov/decade.html | bar.gov   | OK                | 5 years ago    |
    And the following Boosted Content entries exist for the affiliate "bar.gov"
      | url                                   | title             | description                                            |
      | http://bar.gov/hippopotamus-amphibius | Hippopotamus item | large, mostly herbivorous mammal in sub-Saharan Africa |
    And the following featured collections exist for the affiliate "bar.gov":
      | title           | status | publish_start_on |
      | featured item   | active | 2013-07-01       |
    And the following Twitter Profiles exist:
      | screen_name | name          | twitter_id | affiliate  |
      | USASearch   | USASearch.gov | 123456     | bar.gov    |
    And the following Tweets exist:
      | tweet_text                                                                                  | tweet_id | published_ago | twitter_profile_id | url                    | expanded_url            | display_url      |
      | "We wish you all a blessed and safe holiday item." - President Obama http://t.co/l8jbZSbmAX | 184957   | hour          | 123456             | http://t.co/l8jbZSbmAX | http://go.wh.gov/sgCp3q | go.wh.gov/sgCp3q |
    When I am on bar.gov's mobile search page
    And I fill in "Enter your search term" with "items"
    And I press "Search" within the search box
    Then I should see "Everything" within the SERP active navigation
    And I should see "Any time" within the current time filter
    And I should see "Best match" within the current sort by filter
    And I should see "11 RESULTS"
    And I should see "<i> item </i> First news item for the feed"
    And I should see "item Next news item for the feed"
    And I should see "item first Stale news item"
    And I should see "item More news items for the feed"
    And I should see "item Last news item for the feed"
    And I should see "The last hour article"
    And I should see "The last year article"
    And I should see 1 Best Bets Text
    And I should see 1 Best Bets Graphic
    And I should see "blessed and safe"

    When I follow "Last year"
    Then the "Enter your search term" field should contain "items"
    And I should see "Last year" within the current time filter
    And I should see "Best match" within the current sort by filter
    And I should see "9 RESULTS"
    And I should see "<i> item </i> First news item for the feed"
    And I should see "The last hour article"
    And I should see "The last year article"

    When I follow "Most recent"
    Then the "Enter your search term" field should contain "items"
    And I should see "Last year" within the current time filter
    And I should see "Most recent" within the current sort by filter
    And I should see "9 RESULTS"
    And I should see "<i> item </i> First news item for the feed"
    And I should see "The last hour article"
    And I should see "The last year article"

    When I follow "Best match"
    Then the "Enter your search term" field should contain "items"
    And I should see "Last year" within the current time filter
    And I should see "Best match" within the current sort by filter
    And I should see "9 RESULTS"

    And I fill in "Enter your search term" with "last"
    And I press "Search" within the search box
    And I should see "Last year" within the current time filter
    And I should see "Best match" within the current sort by filter
    And I should see "6 RESULTS"

    When I follow "Clear"
    Then the "Enter your search term" field should contain "last"
    And I should see "Any time" within the current time filter
    And I should see "Best match" within the current sort by filter
    And I should see "7 RESULTS"

    When I fill in "Enter your search term" with "body"
    And I press "Search" within the search box
    Then the "Enter your search term" field should contain "body"
    And I should see "Any time" within the current time filter
    And I should see "Best match" within the current sort by filter
    And I should see "3 RESULTS"
    Then I should see "first news item body"
    And I should see "next news item body"
    And I should see "stale news item body"

    When I am on bar.gov's mobile search page
    And there are 30 news items for "Press"
    And I fill in "Enter your search term" with "news item"
    And I press "Search" within the search box
    And I should see "Powered by DIGITALGOV Search"
    And I should see exactly "20" web search results
    And I should see "Previous"
    And I should see a link to "2" with class "pagination-numbered-link"
    And I should see a link to "Next"
    When I follow "Next"
    And I should see exactly "15" web search results
    And I should see a link to "Previous"
    And I should see a link to "1" with class "pagination-numbered-link"
    And I should see "Next"
    When I follow "Previous"
    And I should see exactly "20" web search results

  Scenario: Custom date range blended search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale | gets_blended_results | is_rss_govbox_enabled |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     | true                 | false                 |
      | Spanish site | es.agency.gov | admin@agency.gov | John Bar     | es     | true                 | false                 |
    And affiliate "en.agency.gov" has the following RSS feeds:
      | name          | url                                  | is_navigable |
      | Press         | http://www.whitehouse.gov/feed/press | true         |
    And affiliate "es.agency.gov" has the following RSS feeds:
      | name     | url                                     | is_navigable |
      | Noticias | http://www.whitehouse.gov/feed/noticias | true         |
    And feed "Press" has the following news items:
      | link                             | title       | guid       | published_ago | published_at | description                       | contributor   | publisher    | subject        |
      | http://www.whitehouse.gov/news/1 | First item  | pressuuid1 | day           |              | item First news item for the feed | president     | briefingroom | economy        |
      | http://www.whitehouse.gov/news/2 | Second item | pressuuid2 | day           |              | item Next news item for the feed  | vicepresident | westwing     | jobs           |
      | http://www.whitehouse.gov/news/3 | Third item  | pressuuid3 |               | 2012-10-01   | item Next news item for the feed  | firstlady     | newsroom     | health         |
      | http://www.whitehouse.gov/news/4 | Fourth item | pressuuid4 |               | 2012-10-17   | item Next news item for the feed  | president     | newsroom     | foreign policy |
    And feed "Noticias" has the following news items:
      | link                              | title               | guid    | published_ago | published_at | description                                | subject        |
      | http://www.gobiernousa.gov/news/1 | First Spanish item  | esuuid1 | day           |              | Gobierno item First news item for the feed | economy        |
      | http://www.gobiernousa.gov/news/2 | Second Spanish item | esuuid2 | day           |              | Gobierno item Next news item for the feed  | jobs           |
      | http://www.gobiernousa.gov/news/3 | Third Spanish item  | esuuid3 | day           |              | Gobierno item Next news item for the feed  | health         |
      | http://www.gobiernousa.gov/news/4 | Fourth Spanish item | esuuid4 | day           |              | Gobierno item Next news item for the feed  | foreign policy |
      | http://www.gobiernousa.gov/news/5 | Fifth Spanish item  | esuuid5 | day           | 2012-10-1    | Gobierno item Next news item for the feed  | education      |
      | http://www.gobiernousa.gov/news/6 | Sixth Spanish item  | esuuid6 | day           | 2012-10-17   | Gobierno item Next news item for the feed  | olympics       |
    And the following IndexedDocuments exist:
      | title                           | description                          | url                                   | affiliate     | last_crawl_status | published_at |
      | First indexed document          | first idoc item description          | http://www.whitehouse.gov/first.html  | en.agency.gov | OK                | 2012-10-01   |
      | Second indexed document         | second idoc item description         | http://www.whitehouse.gov/second.html | en.agency.gov | OK                | 2012-10-17   |
      | First Spanish indexed document  | first Spanish idoc item description  | http://es.whitehouse.gov/first.html   | es.agency.gov | OK                | 2012-10-01   |
      | Second Spanish indexed document | second Spanish idoc item description | http://es.whitehouse.gov/second.html  | es.agency.gov | OK                | 2012-10-17   |
    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "item"
    And I press "Search" within the search box
    Then the "Enter your search term" field should contain "item"
    And I should see "Any time" within the current time filter
    And I should see "Best match" within the current sort by filter
    And I should not see a link to "Clear"
    And I should see "6 RESULTS"

    When I fill in "From" with "9/30/2012"
    And I fill in "To" with "10/15/2012"
    And I press "Search" within the custom date search form
    Then the "Enter your search term" field should contain "item"
    And I should see "Sep 30, 2012 - Oct 15, 2012" within the current time filter
    And I should see "Best match" within the current sort by filter
    And I should see a link to "Clear"
    And I should see "2 RESULTS"
    And the "From" field should contain "9/30/2012"
    And the "To" field should contain "10/15/2012"
    And I should see a link to "Third item" with url for "http://www.whitehouse.gov/news/3"
    And I should see a link to "First indexed document" with url for "http://www.whitehouse.gov/first.html"

    When I follow "Most recent"
    Then the "Enter your search term" field should contain "item"
    And I should see "Sep 30, 2012 - Oct 15, 2012" within the current time filter
    And I should see "Most recent" within the current sort by filter
    And I should see a link to "Clear"
    And I should see "2 RESULTS"
    And the "From" field should contain "9/30/2012"
    And the "To" field should contain "10/15/2012"
    And I should see a link to "Third item" with url for "http://www.whitehouse.gov/news/3"
    And I should see a link to "First indexed document" with url for "http://www.whitehouse.gov/first.html"

    When I follow "Any time"
    Then the "Enter your search term" field should contain "item"
    And I should see "Any time" within the current time filter
    And I should see "Most recent" within the current sort by filter
    And I should see a link to "Clear"
    And I should see "6 RESULTS"

    When I follow "Best match"
    Then the "Enter your search term" field should contain "item"
    And I should see "Any time" within the current time filter
    And I should see "Best match" within the current sort by filter
    And I should not see a link to "Clear"
    And I should see "6 RESULTS"

    When I fill in "From" with "9/30/2012"
    And I fill in "To" with "10/15/2012"
    And I press "Search" within the custom date search form
    And I follow "Most recent"
    And I follow "Clear"

    Then the "Enter your search term" field should contain "item"
    And I should see "Any time" within the current time filter
    And I should see "Best match" within the current sort by filter
    And I should not see a link to "Clear"
    And I should see "6 RESULTS"

    When I am on es.agency.gov's search page
    And I fill in "Ingrese su búsqueda" with "item"
    And I press "Buscar" within the search box
    Then I should see "8 RESULTADOS"

    When I fill in "Desde" with "30/9/2012"
    And I fill in "Hasta" with "15/10/2012"
    And I press "Buscar" within the custom date search form
    Then the "Ingrese su búsqueda" field should contain "item"
    And I should see "sep 30, 2012 - oct 15, 2012" within the current time filter
    And I should see "Más relevantes" within the current sort by filter
    And I should see "2 RESULTADOS"
    And the "Desde" field should contain "30/9/2012"
    And the "Hasta" field should contain "15/10/2012"
    And I should see a link to "Fifth Spanish item" with url for "http://www.gobiernousa.gov/news/5"
    And I should see a link to "First Spanish indexed document" with url for "http://es.whitehouse.gov/first.html"

    When I follow "Más recientes"
    Then the "Ingrese su búsqueda" field should contain "item"
    And I should see "sep 30, 2012 - oct 15, 2012" within the current time filter
    And I should see "Más recientes" within the current sort by filter
    And the "Desde" field should contain "30/9/2012"
    And the "Hasta" field should contain "15/10/2012"
    And I should see a link to "Fifth Spanish item" with url for "http://www.gobiernousa.gov/news/5"
    And I should see a link to "First Spanish indexed document" with url for "http://es.whitehouse.gov/first.html"

    When I follow "Cualquier fecha"
    Then the "Ingrese su búsqueda" field should contain "item"
    And I should see "Cualquier fecha" within the current time filter
    And I should see "Más recientes" within the current sort by filter
    And I should see "8 RESULTADOS"

    When I fill in "Desde" with "30/9/2012"
    And I fill in "Hasta" with "15/10/2012"
    And I press "Buscar" within the custom date search form
    And I follow "Borrar"

    And the "Ingrese su búsqueda" field should contain "item"
    And I should see "Cualquier fecha" within the current time filter
    And I should see "Más relevantes" within the current sort by filter
    Then I should see "8 RESULTADOS"

  Scenario: User misspells a query
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | gets_blended_results    | is_rss_govbox_enabled |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | true                    | false                 |
    And the following IndexedDocuments exist:
      | title                       | description                              | url                              | affiliate | last_crawled_at | last_crawl_status |
      | First petition article      | This is an article item on barack obama  | http://p.whitehouse.gov/p-1.html | bar.gov   | 11/02/2011      | OK                |
      | Second barack obama article | This is another article on the same item | http://p.whitehouse.gov/p-2.html | bar.gov   | 11/02/2011      | OK                |
    When I am on bar.gov's mobile search page
    And I fill in "Enter your search term" with "barack obaama article"
    And I press "Search" within the search box
    Then I should see "Showing results for barack obama article"

  Scenario: Custom page 1 results pointer
    Given the following Affiliates exist:
      | display_name | name               | contact_email    | contact_name | locale | page_one_more_results_pointer                                                                           | gets_blended_results |
      | Blended site | blended.agency.gov | admin@agency.gov | John Bar     | en     | Wherever. <a href="https://duckduckgo.com/?q={QUERY}&ia=about">Try your search again</a> to see results | true                 |
    And affiliate "blended.agency.gov" has the following RSS feeds:
      | name          | url                                  | is_navigable |
      | Press         | http://www.whitehouse.gov/feed/press | true         |
    And there are 21 news items for "Press"
    When I am on blended.agency.gov's search page
    And I fill in "Enter your search term" with "news"
    And I press "Search" within the search box
    Then I should see "Wherever. Try your search again to see results"

    When I follow "Next"
    Then I should not see "Wherever. Try your search again to see results"

  Scenario: A site without commercial results
    Given the following Affiliates exist:
      | display_name | name               | contact_email    | contact_name | gets_blended_results | gets_commercial_results_on_blended_search |
      | Blended site | blended.agency.gov | admin@agency.gov | John Bar     | true                 | false                                     |
    And affiliate "blended.agency.gov" has the following RSS feeds:
      | name          | url                                  | is_navigable |
      | Press         | http://www.whitehouse.gov/feed/press | true         |
    And there are 5 news items for "Press"
    When I am on blended.agency.gov's search page
    And I fill in "Enter your search term" with "news"
    And I press "Search" within the search box
    Then I should not see "Try your search again"

  Scenario: Search with only stopwords
    Given the following Affiliates exist:
      | display_name | name               | contact_email    | contact_name | gets_blended_results |
      | Blended site | blended.agency.gov | admin@agency.gov | John Bar     | true                 |
    And affiliate "blended.agency.gov" has the following RSS feeds:
      | name          | url                                  | is_navigable |
      | Press         | http://www.whitehouse.gov/feed/press | true         |
    And there are 5 news items for "Press"
    When I am on blended.agency.gov's search page
    And I fill in "Enter your search term" with "news"
    And I press "Search" within the search box
    And I should see at least "5" web search results
    When I fill in "Enter your search term" with "the with and"
    And I press "Search" within the search box
    Then I should see "Sorry, no results found for 'the with and'."
