# This feature file has been copied and MINIMALLY updated from the original
# legacy_search.feature file. Once these tests are all passing against the current,
# responsive SERP, we should consolidate these with the other features in
# responsive_search.feature and mobile_searches.feature
Feature: Search
  In order to get government-related information from specific affiliate agencies
  As a site visitor
  I want to be able to search for information

  Scenario: Search with a blank query on an affiliate page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | first_name | last_name |
      | bar site         | bar.gov          | aff@bar.gov           | John       | Bar       |
    When I am on bar.gov's search page
    And I press "Search" within the search box
    Then I should see "Please enter a search term"

  Scenario: Search with no results
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | first_name | last_name |
      | bar site         | bar.gov          | aff@bar.gov           | John       | Bar       |
    When I am on bar.gov's search page
    And I fill in "Enter your search term" with "foobarbazbiz"
    And I press "Search" within the search box
    Then I should see "Sorry, no results found for 'foobarbazbiz'. Try entering fewer or broader query terms."

  Scenario: Searching a domain with Bing results that match a specific news item
    # ACHTUNG! This test will fail unless the news item URL matches a url returned by the web search.
    # So if it breaks, check the urls in the VCR cassette recording from the search:
    # features/vcr_cassettes/Legacy_Search/Searching_a_domain_with_Bing_results_that_match_a_specific_news_item.yml
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | domains        |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       | whitehouse.gov |
    And affiliate "bar.gov" has the following RSS feeds:
      | name  | url                                  | is_navigable |
      | Press | http://www.whitehouse.gov/feed/press | true         |
    And feed "Press" has the following news items:
      | link                                                                                    | title              | guid  | published_ago | description       |
      | https://www.whitehouse.gov/about-the-white-house/first-families/hillary-rodham-clinton/ | Clinton RSS Test   | uuid1 | day           | clinton news item |
    When I am on bar.gov's search page
    And I search for "Hillary Rodham Clinton first lady"
    Then I should see "Clinton RSS Test"

  Scenario: No results when searching with active RSS feeds
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name    |
      | bar site     | bar.gov | aff@bar.gov   | John       |Bar           |
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                                | is_navigable |
      | Press         | http://www.whitehouse.gov/feed/press               | true         |
      | Photo Gallery | http://www.whitehouse.gov/feed/media/photo-gallery | true         |
    And feed "Photo Gallery" has the following news items:
      | link                             | title       | guid  | published_ago | description                  |
      | http://www.whitehouse.gov/news/3 | Third item  | uuid3 | week          | item More news items for the feed |
      | http://www.whitehouse.gov/news/4 | Fourth item | uuid4 | week          | item Last news item for the feed  |
    When I am on bar.gov's search page
    And I search for "item"
    Then I should see at least "2" web search results

    When I follow "Press" in the search navbar
    Then I should see "Sorry, no results found for 'item'. Try entering fewer or broader query terms."

    When I follow "Photo Gallery" in the search navbar
    Then I should see "item More news items for the feed"
    When I follow "Last day"
    Then I should see "Sorry, no results found for 'item'. Try entering fewer or broader query terms."
    When I follow "Clear"
    Then I should see at least "2" web search results

  Scenario: No results when searching on Spanish site with active RSS feeds
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | locale |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       | es     |
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                                | is_navigable |
      | Press         | http://www.whitehouse.gov/feed/press               | true         |
      | Photo Gallery | http://www.whitehouse.gov/feed/media/photo-gallery | true         |
    And feed "Photo Gallery" has the following news items:
      | link                             | title       | guid  | published_ago | description                  |
      | http://www.whitehouse.gov/news/3 | Third item  | uuid3 | week          | More news items for the feed |
      | http://www.whitehouse.gov/news/4 | Fourth item | uuid4 | week          | Last news item for the feed  |
    When I am on bar.gov's search page
    And I fill in "query" with "item"
    And I press "Buscar" within the search box
    Then I should see at least "2" web search results

    When I follow "Press" in the search navbar
    Then I should see "No hemos encontrado ningún resultado que contenga 'item'. Intente usar otras palabras clave o sinónimos."

    When I follow "Photo Gallery" in the search navbar
    And I follow "Último día"
    Then I should see "No hemos encontrado ningún resultado que contenga 'item'. Intente usar otras palabras clave o sinónimos."
    When I follow "Borrar"
    Then I should see at least "2" web search results

  Scenario: Searching on a site with media RSS
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       |
    And affiliate "bar.gov" has the following RSS feeds:
      | name   | url                                   | is_navigable | show_only_media_content |
      | Photos | http://www.whitehouse.gov/feed/photos | true         | true                    |
    And feed "Photos" has the following news items:
      | link                              | title   | description     | guid  | published_ago | thumbnail_url                          | content_url                            |
      | http://www.whitehouse.gov/photo/1 | Photo 1 | desc of photo 1 | uuid1 | week          | http://www.whitehouse.gov/media/t1.png | http://www.whitehouse.gov/media/c1.png |
      | http://www.whitehouse.gov/photo/2 | Photo 2 | desc of photo 2 | uuid2 | week          | http://www.whitehouse.gov/media/t2.png | http://www.whitehouse.gov/media/c2.jpg |
      | http://www.whitehouse.gov/photo/3 | Photo 3 | no media        | uuid3 | week          |                                        |                                        |
    When I am on bar.gov's "Photos" news search page
    And I search for "photo"
    Then I should see 2 image results

  Scenario: Visiting English affiliate search with multiple domains
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | domains                |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       | whitehouse.gov,usa.gov |
    When I am on bar.gov's search page
    And I fill in "Enter your search term" with "president"
    And I press "Search" within the search box
    Then I should see at least "2" web search results

  Scenario: Visiting Spanish affiliate search with multiple domains
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | domains                | locale | is_image_search_navigable |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       | whitehouse.gov,usa.gov | es     | true                      |
    When I am on bar.gov's search page
    And I fill in "Ingrese su búsqueda" with "president"
    And I press "Buscar" within the search box
    Then I should see at least "2" web search results
    And I should see "Todo"
    And I should not see "Everything"
    And I should see "Imágenes"
    And I should not see "Images"

  @javascript
  Scenario: Searchers see English Medline Govbox
    Given the following Affiliates exist:
      | display_name | name        | contact_email | first_name | last_name | domains | is_medline_govbox_enabled |
      | english site | english-nih | aff@bar.gov   | John       | Bar       | nih.gov | true                      |
    And the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 67890       | es     | Hippopotomonstrosesquippedaliophobia y otros miedos irracionales |
    When I am on english-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search" within the search box
    Then I should not see "Hippopotomonstrosesquippedaliophobia y otros miedos irracionales"

    Given the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 12345       | en     | Hippopotomonstrosesquippedaliophobia and Other Irrational Fears  |
    And the following Related Medline Topics for "Hippopotomonstrosesquippedaliophobia" in English exist:
      | medline_title | medline_tid | url                                                                          |
      | Hippo1        | 24680       | https://www.nlm.nih.gov/medlineplus/Hippopotomonstrosesquippedaliophobia.html |
    When I am on english-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search" within the search box
    Then I should see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears" within the med topic govbox
    And I should see a link to "Hippo1" with url for "https://www.nlm.nih.gov/medlineplus/Hippopotomonstrosesquippedaliophobia.html"

    Given I am logged in with email "aff@bar.gov"
    When I go to the english-nih's Manage Display page
    And I switch off "Is medline govbox enabled"
    And I press "Save"

    When I am on english-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search" within the search box
    Then I should not see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears"

  @javascript
  Scenario: Searchers see Spanish Medline Govbox
    Given the following Affiliates exist:
      | display_name | name        | contact_email | first_name | last_name | domains | is_medline_govbox_enabled | locale |
      | spanish site | spanish-nih | aff@bar.gov   | John       | Bar       | nih.gov | true                      | es     |
    And the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 12345       | en     | Hippopotomonstrosesquippedaliophobia and Other Irrational Fears  |
    When I am on spanish-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Buscar" within the search box
    Then I should not see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears"

    Given the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 67890       | es     | Hippopotomonstrosesquippedaliophobia y otros miedos irracionales |
    When I am on spanish-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Buscar" within the search box
    Then I should see "Hippopotomonstrosesquippedaliophobia y otros miedos irracionales" within the med topic govbox

    Given I am logged in with email "aff@bar.gov"
    When I go to the spanish-nih's Manage Display page
    And I switch off "Is medline govbox enabled"
    And I press "Save"

    When I am on spanish-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Buscar" within the search box
    Then I should not see "Hippopotomonstrosesquippedaliophobia y otros miedos irracionales"

  Scenario: When a searcher clicks on a collection and the query is blank
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name  |
      | aff site     | aff.gov | aff@bar.gov   | John       | Bar        |
    And affiliate "aff.gov" has the following document collections:
      | name   | prefixes               | is_navigable |
      | Topics | http://aff.gov/topics/ | true         |
    When I go to aff.gov's search page
    And I follow "Topics" in the search navbar
    Then I should see "Please enter a search term"

  # SRCH-2009
  @wip
  Scenario: When a searcher on an English site clicks on an RSS Feed on sidebar and the query is blank
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | first_name | last_name | locale | youtube_handles |
      | bar site         | bar.gov    | aff@bar.gov   | John       | Bar       | en     | en_agency       |
    And affiliate "bar.gov" has the following RSS feeds:
      | name   | url                                  | is_navigable | is_managed |
      | Press  | http://www.whitehouse.gov/feed/press | true         |            |
      | Videos |                                      | true         | true       |
    And feed "Press" has the following news items:
      | link                             | title       | guid  | published_ago | description                       |
      | http://www.whitehouse.gov/news/1 | First item  | uuid1 | day           | item First news item for the feed |
      | http://www.whitehouse.gov/news/2 | Second item | uuid2 | day           | item Next news item for the feed  |
    And feed "en_agency_channel_id" has the following news items:
      | link                                       | title            | guid       | published_ago | description                             |
      | http://www.youtube.com/watch?v=0hLMc-6ocRk | First video item | videouuid1 | day           | item First video news item for the feed |
    When I am on bar.gov's search page
    And I follow "Press" in the left column
    Then I should see the browser page titled "Press - bar site Search Results"
    And I should see "First item"
    And I should see "Second item"
    And I should see "2 results"
    And I should see 2 news results

    When I am on bar.gov's search page
    And I fill in "query" with "first item"
    And I press "Search" within the search box
    And I follow "Videos of 'first item'"
    And I fill in "query" with ""
    And I press "Search" within the search box
    Then I should see the browser page titled "Videos - bar site Search Results"

  # SRCH-2009
  @wip
  Scenario: When a searcher on a Spanish site clicks on an RSS Feed on sidebar and the query is blank
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | first_name | last_name | locale | youtube_handles |
      | Spanish bar site | es.bar.gov | aff@bar.gov   | John       | Bar       | es     | es_agency       |
    And affiliate "es.bar.gov" has the following RSS feeds:
      | name           | url                                  | is_navigable | is_managed |
      | Press          | http://www.whitehouse.gov/feed/press | true         |            |
      | Spanish Videos |                                      | true         | true       |
    And feed "Press" has the following news items:
      | link                             | title       | guid  | published_ago | description                       |
      | http://www.whitehouse.gov/news/1 | Noticia uno | uuid1 | day           | item First news item for the feed |
      | http://www.whitehouse.gov/news/2 | Noticia dos | uuid2 | day           | item Next news item for the feed  |
    And feed "es_agency_channel_id" has the following news items:
      | link                                       | title             | guid       | published_ago | description                             |
      | http://www.youtube.com/watch?v=0hLMc-6ocRk | Noticia video uno | videouuid1 | day           | item First video news item for the feed |
    When I am on es.bar.gov's search page
    And I follow "Press" in the left column
    Then I should see the browser page titled "Press - Spanish bar site resultados de la búsqueda"
    Then I should see "2 resultados"
    And I should see 2 news results
    And I should see "Noticia uno"
    And I should see "Noticia dos"

    When I am on es.bar.gov's search page
    And I fill in "query" with "noticia uno"
    And I press "Buscar" within the search box
    And I follow "Videos de 'noticia uno'"
    And I fill in "query" with ""
    And I press "Buscar" within the search box
    Then I should see the browser page titled "Spanish Videos - Spanish bar site resultados de la búsqueda"

  Scenario: When there are relevant Tweets from Twitter profiles associated with the affiliate
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | locale |
      | bar site     | bar.gov    | aff@bar.gov   | John       | Bar       | en     |
      | spanish site | es.bar.gov | aff@bar.gov   | John       | Bar       | es     |
    And the following Twitter Profiles exist:
      | screen_name | name            | twitter_id | affiliate  |
      | USAgov      | USA.gov         | 123        | bar.gov    |
      | GobiernoUSA | GobiernoUSA.gov | 456        | es.bar.gov |
    And the following Tweets exist:
      | tweet_text                     | tweet_id | published_ago | twitter_profile_id | url                  | expanded_url                 | display_url           |
      | Summer season is great!        | 234567   | year          | 123                |                      |                              |                       |
      | Ok season http://t.co/YQQSs9bb | 184957   | hour          | 123                | http://t.co/YQQSs9bb | http://tmblr.co/Z8xAVxUEKvaK | tmblr.co/Z8xAVxUEK... |
      | Estados Unidos por amigos!     | 789012   | hour          | 456                |                      |                              |                       |
    When I am on bar.gov's search page
    And I search for "season"
    Then I should see "Ok season"
    And I should see "about 1 hour ago"
    And I should see a link to "USAgov" with url for "https://twitter.com/USAgov"
    And I should see "USA.gov @USAgov"
    And I should see a link to "http://t.co/YQQSs9bb" with text "tmblr.co/Z8xAVxUEK..."
    And I should see "season" in bold font
    And I should not see "Summer season is great!"

    When I am on es.bar.gov's search page
    And I fill in "query" with "Estados Unidos amiga"
    And I press "Buscar" within the search box
    Then I should see a link to "GobiernoUSA.gov" with url for "https://twitter.com/GobiernoUSA"
    And I should see "GobiernoUSA.gov @GobiernoUSA"
    And I should see "Estados Unidos por amigos!"
    And I should see "Hace una hora"
    And I should see "Estados" in bold font in the twitter govbox
    And I should see "Unidos" in bold font in the twitter govbox
    And I should see "amigos" in bold font in the twitter govbox

  Scenario: Searching document collections
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains        |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar     | whitehouse.gov |
    And affiliate "agency.gov" has the following document collections:
      | name      | prefixes                 | is_navigable |
      | Petitions | petitions.whitehouse.gov | true         |
    And the following IndexedDocuments exist:
      | title                   | description                                         | url                                             | affiliate  | last_crawled_at | last_crawl_status |
      | First petition article  | This is an article death star r2d2 xyz3 petition    | http://petitions.whitehouse.gov/petition-1.html | agency.gov | 11/02/2011      | OK                |
      | Second petition article | This is an article on death r2d2 xyz3 star petition | http://petitions.whitehouse.gov/petition-2.html | agency.gov | 11/02/2011      | OK                |
    When I am on agency.gov's search page
    And I follow "Petitions" in the search navbar
    And I search for "death star r2d2 xyz3"
    Then I should see a link to "First petition article" with url for "http://petitions.whitehouse.gov/petition-1.html"
    And I should see a link to "Second petition article" with url for "http://petitions.whitehouse.gov/petition-2.html"

  Scenario: Searching on non navigable document collection
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar       | usa.gov |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes                  | is_navigable |
      | Blog | https://www.sba.gov/blogs | false        |
      | Web  | https://www.usa.gov       | true         |
    When I am on agency.gov's "Blog" docs search page
    Then I should see "Blog" in the search navbar
    And I should not see a link to "Web"
    And I should not see a link to "Blog"
    When I search for "sba"
    Then I should see at least "1" web search results
    And I should not see a link to "Blog" in the search navbar

  Scenario: Searching with malformed query
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | is_image_search_navigable |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar       | true                      |
    When I am on agency.gov's search page
    And I search for "<b>hello</b><script>script</script>"
    Then I should see "hello"
    And I should not see "script"
    And I should see a link to "Images" with url that ends with "query=hello" in the search navbar

  # SRCH-2009
  @wip
  Scenario: Searching for site specific results using query
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar       | usa.gov |
    When I am on agency.gov's search page
    And I fill in "query" with "jobs site:www.usa.gov"
    And I press "Search" within the search box
    Then I should see "www.usa.gov/"
    And I fill in "query" with "jazz site:wikipedia.org"
    And I press "Search" within the search box
    Then I should not see "en.wikipedia.org/wiki/Jazz"

  Scenario: Searching for site specific results using sitelimit
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains | is_image_search_navigable |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar       | .gov    | true                      |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes                         | is_navigable |
      | Blog | http://search.gov/blog/          | true         |
    When I am on agency.gov's search page with site limited to "www.usa.gov"
    And I search for "jobs"
    Then I should see at least "10" web search results
    And every result URL should match "www.usa.gov"

    When I follow "Blog" in the search navbar
    Then I should see at least "1" web search results
    And every result URL should match "search.gov/blog"

  Scenario: Visiting affiliate with strictui parameters
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | external_css_url                | header                                                                  | footer                                                                  |
      | aff site     | aff.gov | aff@bar.gov   | John       | Bar       | http://cdn.aff.gov/external.css | <style>#my_header { color:red } </style> <h1 id='my_header'>header</h1> | <style>#my_footer { color:red } </style> <h1 id='my_footer'>footer</h1> |
    When I go to aff.gov's strictui search page
    Then I should not see the page with external affiliate stylesheet "http://cdn.aff.gov/external.css"
    And I should not see tainted SERP header
    And I should not see tainted SERP footer

  Scenario: Affiliate search on affiliate with connections
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | domains |
      | agency site  | agency.gov | aff@bar.gov   | John       | Bar       | epa.gov |
      | other site   | other.gov  | aff@bad.gov   | John       | Bad       | cdc.gov |
    And the following Connections exist for the affiliate "agency.gov":
    | connected_affiliate   |   display_name    |
    | other.gov             |  Other Site       |
    When I am on agency.gov's search page
    And I search for "jobs"
    Then I should see at least "10" web search results
    And every result URL should match "epa.gov"
    And I should see "Other Site"
    When I follow "Other Site" in the search navbar
    Then I should see the browser page titled "jobs - other site Search Results"
    And I should see at least "10" web search results
    And every result URL should match "cdc.gov"

  Scenario: Searching on sites with Featured Collections
    Given the following Affiliates exist:
      | display_name   | name          | contact_email   | first_name | last_name | locale |
      | agency site    | agency.gov    | john@agency.gov | John       | Bar       | en     |
    And the following featured collections exist for the affiliate "agency.gov":
      | title           | title_url                         | status   | publish_start_on | publish_end_on |
      | Tornado Warning | http://agency.gov/tornado-warning | active   | 2013-07-01       |                |
    And the following featured collection links exist for featured collection titled "Tornado Warning":
      | title                 | url                                          |
      | Atlantic              | http://www.nhc.noaa.gov/aboutnames.shtml#atl |
      | Eastern North Pacific | http://www.nhc.noaa.gov/aboutnames.shtml#enp |
    When I am on agency.gov's search page
    And I fill in "query" with "warnings for a tornado"
    And I press "Search" within the search box
    Then I should see "Tornado Warning" in the boosted contents section
    And I should see a link to "Atlantic" with url for "http://www.nhc.noaa.gov/aboutnames.shtml#atl"
    And I should see a link to "Eastern North Pacific" with url for "http://www.nhc.noaa.gov/aboutnames.shtml#enp"
    When I fill in "query" with "Atlantic"
    And I press "Search" within the search box
    Then I should see a featured collection link title with "Atlantic" highlighted

  Scenario: Searching on sites with Boosted Contents
    Given the following Affiliates exist:
      | display_name   | name          | contact_email   | first_name| last_name | locale |
      | agency site    | agency.gov    | john@agency.gov | John      | Bar       | en     |
      | es agency site | es.agency.gov | john@agency.gov | John      | Bar       | es     |
    And the following Boosted Content entries exist for the affiliate "agency.gov"
      | url                                        | title                               | description        | status   | publish_start_on | publish_end_on |
      | http://search.gov/releases/2013-05-31.html | Notes for Week Ending May 31, 2013  | multimedia gallery | active   | 2013-08-01       | 2022-01-01     |
      | http://search.gov/releases/2013-06-21.html | Notes for Week Ending June 21, 2013 | spring cleaning    | inactive |                  |                |
    And the following Boosted Content entries exist for the affiliate "es.agency.gov"
      | title                             | url                       | description |
      | la página de prueba de Emergencia | http://www.agency.gov/911 | Some terms  |
    When I am on agency.gov's search page
    And I fill in "query" with "notes"
    And I press "Search" within the search box
    Then I should see a link to "Notes for Week Ending May 31, 2013" with url for "http://search.gov/releases/2013-05-31.html" in the boosted contents section
    And I should not see a link to "Notes for Week Ending June 21, 2013"

    When I am on es.agency.gov's search page
    And I fill in "query" with "emergencia"
    And I press "Buscar" within the search box
    Then I should see a link to "la página de prueba de Emergencia" with url for "http://www.agency.gov/911" in the boosted contents section

  Scenario: Entering a blank advanced search
    Given the following Affiliates exist:
      | display_name | name   | contact_email | first_name | last_name | header         |
      | USA.gov      | usagov | aff@bar.gov   | John       | Bar       | USA.gov Header |
    When I am on usagov's advanced search page
    And I press "Search"
    Then I should be on the search page
    And I should see "Please enter a search term"

  Scenario: When using tablet device on advanced search
    Given I am using an tabletPC device
    And the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       |
    When I am on bar.gov's advanced search page
    And I press "Search"
    Then I should be on the search page
    And I should see "Please enter a search term"
