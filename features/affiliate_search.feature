Feature: Affiliate Search
  In order to get government-related information from specific affiliate agencies
  As a site visitor
  I want to be able to search for information

  Scenario: Search with a blank query on an affiliate page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    When I am on bar.gov's search page
    And I press "Search"
    Then I should see "Please enter search term(s)"

  Scenario: Setting a Left-nav Label
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "bar.gov" selected
    And I follow "Sidebar"
    And I fill in "Sidebar Label" with "MY AWESOME LABEL"
    And I press "Save"
    When I go to bar.gov's search page
    Then I should see "MY AWESOME LABEL"

  Scenario: Searching with active RSS feeds
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | contact_name | locale |
      | bar site         | bar.gov    | aff@bar.gov   | John Bar     | en     |
      | Spanish bar site | es.bar.gov | aff@bar.gov   | John Bar     | es     |
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                                                  | is_navigable | shown_in_govbox |
      | Press         | http://www.whitehouse.gov/feed/press                                 | true         | true            |
      | Photo Gallery | http://www.whitehouse.gov/feed/media/photo-gallery                   | true         | true            |
      | Videos        | http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse | true         | true            |
      | Hide Me       | http://www.whitehouse.gov/feed/media/photo-gallery                   | false        | false           |
    And affiliate "es.bar.gov" has the following RSS feeds:
      | name           | url                                                                    | is_navigable | shown_in_govbox |
      | Noticias       | http://www.usa.gov/gobiernousa/rss/actualizaciones-articulos.xml       | true         | true            |
      | Spanish Videos | http://gdata.youtube.com/feeds/base/videos?alt=rss&author=eswhitehouse | true         | true            |
    And feed "Press" has the following news items:
      | link                             | title       | guid  | published_ago | description                  |
      | http://www.whitehouse.gov/news/1 | First item  | uuid1 | day           | item First news item for the feed |
      | http://www.whitehouse.gov/news/2 | Second item | uuid2 | day           | item Next news item for the feed  |
    And feed "Photo Gallery" has the following news items:
      | link                             | title       | guid  | published_ago | description                  |
      | http://www.whitehouse.gov/news/3 | Third item  | uuid3 | week          | item More news items for the feed |
      | http://www.whitehouse.gov/news/4 | Fourth item | uuid4 | week          | item Last news item for the feed  |
    And feed "Videos" has the following news items:
      | link                                       | title             | guid       | published_ago | description                              |
      | http://www.youtube.com/watch?v=0hLMc-6ocRk | First video item  | videouuid5 | day           | item First video news item for the feed  |
      | http://www.youtube.com/watch?v=R2RWscJM97U | Second video item | videouuid6 | day           | item Second video news item for the feed |
    And feed "Hide Me" has the following news items:
      | link                                    | title             | guid        | published_ago | description                    |
      | http://www.whitehouse.gov/news/hidden/1 | First hidden item | hiddenuuid1 | week          | First hidden news for the feed |
    And feed "Noticias" has the following news items:
      | link                              | title               | guid    | published_ago | description                                |
      | http://www.gobiernousa.gov/news/1 | First Spanish item  | esuuid1 | day           | Gobierno item First news item for the feed |
      | http://www.gobiernousa.gov/news/2 | Second Spanish item | esuuid2 | day           | Gobierno item Next news item for the feed  |
    And feed "Spanish Videos" has the following news items:
      | link                                       | title                     | guid     | published_ago | description                           |
      | http://www.youtube.com/watch?v=EqExXXahb0s | First Spanish video item  | esvuuid1 | day           | Gobierno video news item for the feed |
      | http://www.youtube.com/watch?v=C5WWyZ0cTcM | Second Spanish video item | esvuuid2 | day           | Gobierno video news item for the feed |
    And the following SAYT Suggestions exist for bar.gov:
      | phrase           |
      | Some Unique item |
      | el paso term     |
    When I am on bar.gov's search page
    And I fill in "query" with "first item"
    And I press "Search"
    Then I should see "News for 'first item' by bar site"
    And I should see "First item" in the rss feed govbox
    And I should not see "First video item" in the rss feed govbox
    And I should see "Videos of 'first item' by bar site"
    And I should see "First video item" in the video rss feed govbox
    And I should not see "First item" in the video rss feed govbox
    And I should not see "First hidden item"

    When I follow "News for 'first item'"
    Then I should be on the news search page
    And I should have the following query string:
      |affiliate|bar.gov   |
      |query    |first item|
      |m        |false     |
    And I should see "First item"
    And I should see "First video item"

    When I am on bar.gov's search page
    And I fill in "query" with "first item"
    And I press "Search"
    And I follow "Videos of 'first item'"
    Then I should have the following query string:
      |affiliate|bar.gov   |
      |query    |first item|
      |m        |false     |
    And I should see "Videos" in the left column
    And I should not see a link to "Videos"
    Then I should see "First video item"
    And I should not see "First item"
    When I follow "Last year" in the left column
    Then I should see "Videos" in the left column
    And I should not see a link to "Videos"
    And I should see "First video item"
    And I should not see "First item"

    When I am on bar.gov's search page
    And I fill in "query" with "loren"
    And I press "Search"
    Then I should not see "News for 'loren' from bar site"

    When there are 30 video news items for "Videos"
    And I am on bar.gov's search page
    And I follow "Videos"
    Then I should see "32 results"
    And I should see 20 video news results

    When I am on es.bar.gov's search page
    And I fill in "query" with "first item"
    And I press "Buscar"
    Then I should see "Videos de 'first item' de Spanish bar site"
    And I should see "First Spanish video item" in the video rss feed govbox

    When I am on bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search"
    Then I should see "Everything"
    And I should see "Images"
    And I should see "Press"
    And I should see "Photo Gallery"
    And I should see "Videos"
    And I should not see "Hide Me"
    And I should not see "All Time"
    And I should not see "Last hour"
    And I should not see "Last day"
    And I should not see "Last week"
    And I should not see "Last month"
    And I should not see "Last year"

    When I follow "Videos"
    Then I should see the browser page titled "item - bar site Search Results"
    And I should see 20 youtube thumbnails
    And I should see youtube thumbnail for "First video item"
    And I should see yesterday's date in the English search results

    When I follow "Last year"
    And I follow "Everything"
    Then I should see the browser page titled "item - bar site Search Results"
    And I should not see "First hidden item"

    When I follow "Press"
    And I follow "Last week"
    Then I should see the browser page titled "item - bar site Search Results"
    And I should see "item First news item for the feed"
    And I should see "item Next news item for the feed"
    And I should not see "item More news items for the feed"
    And I should not see "item Last news item for the feed"
    And I should see "Related Searches" in the search results section
    And I should see "Search" button

    When I follow "Last hour"
    Then I should see "no results found for 'item'"

    When I follow "Everything"
    Then I should not see a link to "Everything"

    When I follow "Photo Gallery"
    Then I should see "no results found for 'item'"

    When I follow "All Time"
    Then I should see "item More news items for the feed"
    And I should see "item Last news item for the feed"

    When I follow "Everything"
    Then I should see "Advanced Search"
    And I should see "Search" button

    When I am on es.bar.gov's search page
    And I fill in "query" with "gobierno"
    And I press "Buscar"
    Then I should see "gobierno - Spanish bar site resultados de la búsqueda"
    And I should see "Todo"
    And I should not see "Everything"
    And I should see "Imágenes"
    And I should see "Spanish Videos"
    And I should not see "Images"
    And I should not see "Search this site"
    And I should not see "Cualquier fecha"
    And I should not see "All Time"
    And I should see "Noticias sobre de 'gobierno' de Spanish bar site"
    And I should see "Videos de 'gobierno' de Spanish bar site"

    When I follow "Noticias sobre de 'gobierno'"
    Then I should see "Spanish item"
    And I should see "Spanish video item"

    When I am on es.bar.gov's search page
    And I fill in "query" with "gobierno"
    And I press "Buscar"
    And I follow "Videos de 'gobierno'"
    Then I should see "Spanish video item"
    And I should not see "Spanish item"

    When I am on es.bar.gov's search page
    And I fill in "query" with "gobierno"
    And I press "Buscar"
    And I follow "Spanish Videos"
    Then I should see "Cualquier fecha"
    And I should see 2 youtube thumbnails
    And I should see youtube thumbnail for "First Spanish video item"
    And I should see yesterday's date in the Spanish search results

  Scenario: Searching a domain with Bing results that match a specific news item
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | usa.gov |
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                                                  | is_navigable | shown_in_govbox |
      | Press         | http://www.whitehouse.gov/feed/press                                 | true         | true            |
    And feed "Press" has the following news items:
      | link                             | title       | guid  | published_ago | description                  |
      | http://answers.usa.gov/system/selfservice.controller?CONFIGURATION=1000&PARTITION_ID=1&CMD=VIEW_ARTICLE&USERTYPE=1&LANGUAGE=en&COUNTRY=US&ARTICLE_ID=11351       | First item  | uuid1 | day           | item First news item for the feed |
    When I am on bar.gov's search page
    And I fill in "query" with "president"
    And I press "Search"
    Then I should see "1 day ago"

  Scenario: No results when searching with active RSS feeds
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     |
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                                | is_navigable |
      | Press         | http://www.whitehouse.gov/feed/press               | true         |
      | Photo Gallery | http://www.whitehouse.gov/feed/media/photo-gallery | true         |
    And feed "Photo Gallery" has the following news items:
      | link                             | title       | guid  | published_ago | description                  |
      | http://www.whitehouse.gov/news/3 | Third item  | uuid3 | week          | item More news items for the feed |
      | http://www.whitehouse.gov/news/4 | Fourth item | uuid4 | week          | item Last news item for the feed  |
    When I am on bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search"
    Then I should see at least 2 search results

    When I follow "Press"
    Then I should see "Sorry, no results found for 'item'. Remove all filters or try entering fewer or broader query terms."
    When I follow "Remove all filters"
    Then I should see at least 2 search results

    When I fill in "query" with "item"
    And I press "Search"
    And I follow "Photo Gallery"
    Then I should see "item More news items for the feed"
    When I follow "Last day"
    Then I should see "Sorry, no results found for 'item' in the last day. Remove all filters or try entering fewer or broader query terms."
    When I follow "Remove all filters"
    Then I should see at least 2 search results

  Scenario: No results when searching on Spanish site with active RSS feeds
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | locale |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | es     |
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
    And I press "Buscar"
    Then I should see at least 2 search results

    When I follow "Press"
    Then I should see "No hemos encontrado ningún resultado que contenga 'item'. Elimine los filtros de su búsqueda, use otras palabras clave o intente usando sinónimos."
    When I follow "Elimine los filtros"
    Then I should see at least 2 search results

    When I fill in "query" with "item"
    And I press "Buscar"
    And I follow "Photo Gallery"
    And I follow "Último día"
    Then I should see "No hemos encontrado ningún resultado que contenga 'item' en el último día. Elimine los filtros de su búsqueda, use otras palabras clave o intente usando sinónimos."
    When I follow "Elimine los filtros"
    Then I should see at least 2 search results

  Scenario: Visiting English affiliate search with multiple domains
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains                |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | whitehouse.gov,usa.gov |
    When I am on bar.gov's search page
    And I fill in "query" with "president"
    And I press "Search"
    Then I should see at least 2 search results
    And I should not see "Search this site"

  Scenario: Visiting Spanish affiliate search with multiple domains
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains                | locale |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | whitehouse.gov,usa.gov | es     |
    When I am on bar.gov's search page
    And I fill in "query" with "president"
    And I press "Buscar"
    Then I should see at least 2 search results
    And I should see "Todo"
    And I should not see "Everything"
    And I should see "Imágenes"
    And I should not see "Images"
    And I should not see "Search this site"

  Scenario: Highlighting query terms
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains        |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | search.usa.gov |
    When I am on bar.gov's search page
    And I fill in "query" with "U.S. Government's Official Search Engine"
    And I press "Search"
    Then I should see "Search.USA.gov"
    And I should not see "Search.USA.gov" in bold font

    When I fill in "query" with "search.usa.gov"
    And I press "Search"
    Then I should see "Search.USA.gov" in bold font

  Scenario: Filtering indexed documents when they are duplicated in Bing search results
    Given the following Affiliates exist:
      | display_name | name       | contact_email  | contact_name |
      | agency site  | agency.gov | aff@agency.gov | John Bar     |
    And the following IndexedDocuments exist:
      | title        | description                                                                         | url                 | affiliate  | last_crawl_status |
      | USA.gov Blog | We help you find official U.S. government information and services on the Internet. | http://blog.usa.gov | agency.gov | OK                |
    When I am on agency.gov's search page
    And I fill in "query" with "usa.gov blog"
    And I press "Search"
    Then I should not see "See more document results"

  Scenario: Searchers see agency deep links in English
    Given the following Affiliates exist:
      | display_name | name       | contact_email  | contact_name | domains | is_agency_govbox_enabled  |
      | agency site  | ssa.gov    | aff@agency.gov | John Bar     | ssa.gov | true                      |
    And the following Agency entries exist:
      | name | domain  |
      | SSA  | ssa.gov |
    And the following Agency Urls exist:
      | name | locale | url                         |
      | SSA  | en     | http://www.ssa.gov/         |
      | SSA  | es     | http://www.ssa.gov/espanol/ |
    And I am logged in with email "aff@agency.gov" and password "random_string"
    When I am on ssa.gov's search page
    And I fill in "query" with "ssa"
    And I press "Search"
    Then I should see agency govbox deep links

  Scenario: Searching within an agency on English SERP
    Given the following Affiliates exist:
      | display_name    | name        | contact_email | contact_name | domains | search_results_page_title                      | is_agency_govbox_enabled | locale |
      | USA.gov         | usagov      | aff@bar.gov   | John Bar     | .gov    | {Query} - {SiteName} Search Results            | true                     | en     |
      | GobiernoUSA.gov | gobiernousa | aff@bar.gov   | John Bar     | .gov    | {Query} - {SiteName} resultados de la búsqueda | true                     | es     |
    And the following Agency entries exist:
      | name | domain  |
      | SSA  | ssa.gov |
    And the following Agency Urls exist:
      | name | locale | url                         |
      | SSA  | en     | http://www.ssa.gov/         |
      | SSA  | es     | http://www.ssa.gov/espanol/ |
    When I am on usagov's search page
    And I fill in "query" with "ssa"
    And I press "Search"
    Then I should see the agency govbox
    When I fill in "query" with "benefits" in the agency govbox
    And I press "Search" in the agency govbox
    Then I should see the browser page titled "benefits site:ssa.gov - USA.gov Search Results"
    And the "query" field should contain "benefits site:ssa.gov"

  Scenario: Searchers see English Medline Govbox
    Given the following Affiliates exist:
      | display_name | name        | contact_email | contact_name | domains | is_medline_govbox_enabled |
      | english site | english-nih | aff@bar.gov   | John Bar     | nih.gov | true                      |
    And the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 67890       | es     | Hippopotomonstrosesquippedaliophobia y otros miedos irracionales |
    When I am on english-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search"
    Then I should not see "Hippopotomonstrosesquippedaliophobia y otros miedos irracionales"

    Given the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 12345       | en     | Hippopotomonstrosesquippedaliophobia and Other Irrational Fears  |
    And the following Related Medline Topics for "Hippopotomonstrosesquippedaliophobia" in English exist:
      | medline_title | medline_tid | summary_html   |
      | Hippo1        | 24680       | Hippo1 summary |
    When I am on english-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search"
    Then I should see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears" in the medline govbox
    When I follow "Hippo1" in the medline govbox
    Then I should see "Hippo1 - english site Search Results"

    Given I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "english-nih" selected
    And I follow "Results modules"
    And I uncheck "Is medline govbox enabled"
    And I press "Save"

    When I am on english-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search"
    Then I should not see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears"

  Scenario: Searchers see Spanish Medline Govbox
    Given the following Affiliates exist:
      | display_name | name        | contact_email | contact_name | domains | is_medline_govbox_enabled | locale |
      | spanish site | spanish-nih | aff@bar.gov   | John Bar     | nih.gov | true                      | es     |
    And the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 12345       | en     | Hippopotomonstrosesquippedaliophobia and Other Irrational Fears  |
    When I am on spanish-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Buscar"
    Then I should not see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears"

    Given the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 67890       | es     | Hippopotomonstrosesquippedaliophobia y otros miedos irracionales |
    When I am on spanish-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Buscar"
    Then I should see "Hippopotomonstrosesquippedaliophobia y otros miedos irracionales" in the medline govbox

    Given I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "spanish-nih" selected
    And I follow "Results modules"
    And I uncheck "Is medline govbox enabled"
    And I press "Save"

    When I am on spanish-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Buscar"
    Then I should not see "Hippopotomonstrosesquippedaliophobia y otros miedos irracionales"

  Scenario: When an affiliate uses ODIE results
    Given the following Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains | results_source |
      | agency site  | nih.gov    | aff@bar.gov   | John Bar     | nih.gov | odie           |
    And the following IndexedDocuments exist:
      | url                       | affiliate | title       | description     |
      | http://nih.gov/1.html     | nih.gov   | NIH Page 1  | This is page 1  |
      | http://nih.gov/2.html     | nih.gov   | NIH Page 2  | This is page 2  |
    And the url "http://nih.gov/1.html" has been crawled
    And the url "http://nih.gov/2.html" has been crawled
    And I am on nih.gov's search page
    And I fill in "query" with "NIH"
    And I press "Search"
    Then I should not see the indexed documents section
    And I should see "NIH Page 1"
    And I should see "NIH Page 2"

  Scenario: Searcher does not see indexed documents when using Bing-only results
    Given the following Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains | results_source |
      | agency site  | nih.gov    | aff@bar.gov   | John Bar     | nih.gov | bing           |
    And the following IndexedDocuments exist:
      | url                       | affiliate | title       | description     |
      | http://nih.gov/1.html     | nih.gov   | NIH Page 1  | This is page 1  |
      | http://nih.gov/2.html     | nih.gov   | NIH Page 2  | This is page 2  |
    And the url "http://nih.gov/1.html" has been crawled
    And the url "http://nih.gov/2.html" has been crawled
    And I am on nih.gov's search page
    And I fill in "query" with "NIH"
    And I press "Search"
    Then I should not see the indexed documents section
    And I should not see "NIH Page 1"
    And I should not see "NIH Page 2"

  Scenario: When an affiliate uses Bing+Odie results
    Given the following Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains | results_source |
      | agency site  | nih.gov    | aff@bar.gov   | John Bar     | nih.gov | bing+odie      |
    And the following IndexedDocuments exist:
      | url                     | affiliate | title                 | description              | last_crawl_status | created_at   |
      | http://nih.gov/old.html | nih.gov   | NIH Post 4 months ago | This is the NIH old page | OK                | 4 months ago |
      | http://nih.gov/2.html   | nih.gov   | NIH Post 9 weeks ago  | This is post 9           | OK                | 9 weeks ago  |
      | http://nih.gov/1.html   | nih.gov   | NIH Post 10 weeks ago | This is post 10          | OK                | 10 weeks ago |
    And the url "http://nih.gov/1.html" has been crawled
    And the url "http://nih.gov/2.html" has been crawled
    And I am on nih.gov's search page
    And I fill in "query" with "NIH"
    And I press "Search"
    Then I should see "NIH Post 9 weeks ago" in the indexed documents section
    And I should see "NIH Post 10 weeks ago" in the indexed documents section
    And I should not see "NIH Post 4 months ago" in the indexed documents section

  Scenario: When an affiliate has scope keywords
    Given the following Affiliates exist:
      | display_name | name           | contact_email | contact_name | domains | scope_keywords |
      | agency site  | whitehouse.gov | aff@bar.gov   | John Bar     | nih.gov | green button   |
    And I am on whitehouse.gov's search page
    And I fill in "query" with "obama"
    And I press "Search"
    Then I should not see "Green Button" in bold font

  Scenario: When an affiliate has scope keywords, and searches for those keywords
    Given the following Affiliates exist:
      | display_name | name           | contact_email | contact_name | domains | scope_keywords |
      | agency site  | whitehouse.gov | aff@bar.gov   | John Bar     | nih.gov | green button   |
    And I am on whitehouse.gov's search page
    And I fill in "query" with "green button"
    And I press "Search"
    Then I should see "green button" in bold font

  Scenario: When a searcher enter query with invalid solr character
    Given the following Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     | .gov    |
    And I am on agency.gov's search page
    And I fill in "query" with "++health it"
    And I press "Search"
    Then I should see the browser page titled "++health it - agency site Search Results"
    And I should see some Bing search results
    When I fill in "query" with "OR US97 central"
    And I press "Search"
    Then I should see the browser page titled "OR US97 central - agency site Search Results"
    And I should see some Bing search results

  Scenario: When a searcher clicks on a collection on sidebar and the query is blank
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And affiliate "aff.gov" has the following document collections:
      | name   | prefixes               | is_navigable |
      | Topics | http://aff.gov/topics/ | true         |
    When I go to aff.gov's search page
    And I follow "Topics" in the left column
    Then I should see "Please enter search term(s)"

  Scenario: When a searcher on an English site clicks on an RSS Feed on sidebar and the query is blank
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | contact_name | locale |
      | bar site         | bar.gov    | aff@bar.gov   | John Bar     | en     |
    And affiliate "bar.gov" has the following RSS feeds:
      | name   | url                                                                  | is_navigable | shown_in_govbox |
      | Press  | http://www.whitehouse.gov/feed/press                                 | true         | true            |
      | Videos | http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse | true         | true            |
    And feed "Press" has the following news items:
      | link                             | title       | guid  | published_ago | description                       |
      | http://www.whitehouse.gov/news/1 | First item  | uuid1 | day           | item First news item for the feed |
      | http://www.whitehouse.gov/news/2 | Second item | uuid2 | day           | item Next news item for the feed  |
    And feed "Videos" has the following news items:
      | link                                       | title            | guid       | published_ago | description                             |
      | http://www.youtube.com/watch?v=0hLMc-6ocRk | First video item | videouuid1 | day           | item First video news item for the feed |
    When I am on bar.gov's search page
    And I follow "Press" in the left column
    Then I should see the browser page titled "Press - bar site Search Results"
    Then I should see "2 results"
    And I should see 2 news results
    And I should see "First item"
    And I should see "Second item"

    When I am on bar.gov's search page
    And I fill in "query" with "first item"
    And I press "Search"
    And I follow "Videos of 'first item'"
    And I fill in "query" with ""
    And I press "Search"
    Then I should see the browser page titled "Videos - bar site Search Results"

  Scenario: When a searcher on a Spanish site clicks on an RSS Feed on sidebar and the query is blank
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | contact_name | locale |
      | Spanish bar site | es.bar.gov | aff@bar.gov   | John Bar     | es     |
    And affiliate "es.bar.gov" has the following RSS feeds:
      | name           | url                                                                  | is_navigable | shown_in_govbox |
      | Press          | http://www.whitehouse.gov/feed/press                                 | true         | true            |
      | Spanish Videos | http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse | true         | true            |
    And feed "Press" has the following news items:
      | link                             | title               | guid  | published_ago | description                       |
      | http://www.whitehouse.gov/news/1 | First Spanish item  | uuid1 | day           | item First news item for the feed |
      | http://www.whitehouse.gov/news/2 | Second Spanish item | uuid2 | day           | item Next news item for the feed  |
    And feed "Spanish Videos" has the following news items:
      | link                                       | title            | guid       | published_ago | description                             |
      | http://www.youtube.com/watch?v=0hLMc-6ocRk | First video item | videouuid1 | day           | item First video news item for the feed |
    When I am on es.bar.gov's search page
    And I follow "Press" in the left column
    Then I should see the browser page titled "Press - Spanish bar site resultados de la búsqueda"
    Then I should see "2 resultados"
    And I should see 2 news results
    And I should see "First Spanish item"
    And I should see "Second Spanish item"

    When I am on es.bar.gov's search page
    And I fill in "query" with "first item"
    And I press "Buscar"
    And I follow "Videos de 'first item'"
    And I fill in "query" with ""
    And I press "Buscar"
    Then I should see the browser page titled "Spanish Videos - Spanish bar site resultados de la búsqueda"

  Scenario: When there are relevant Tweets from Twitter profiles associated with the affiliate
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | contact_name | locale | is_twitter_govbox_enabled |
      | bar site         | bar.gov    | aff@bar.gov   | John Bar     | en     | true                      |
    And the following Twitter Profiles exist:
      | screen_name   | twitter_id  | affiliate |
      | USASearch     | 123         | bar.gov   |
    And the following Tweets exist:
      | tweet_text          | tweet_id    | published_at        | twitter_profile_id  |
      | AMERICA is great!   | 123456      | 2012-05-01 00:00:00 | 123                 |
    When I am on bar.gov's search page
    And I fill in "query" with "america"
    And I press "Search"
    Then I should see "Recent tweet for america (@USASearch)"
    And I should see "AMERICA is great!"
    And I should see "AMERICA" in bold font

  Scenario: Enabling and disabling the Twitter govbox
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | contact_name | locale |
      | bar site         | bar.gov    | aff@bar.gov   | John Bar     | en     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "bar.gov" selected
    And I follow "Results modules"
    Then I should not see "Recent Tweets"

    Given the following Twitter Profiles exist:
      | screen_name   | twitter_id  | affiliate |
      | USASearch     | 123         | bar.gov   |
    And the following Tweets exist:
      | tweet_text          | tweet_id    | published_at        | twitter_profile_id  |
      | AMERICA is great!   | 123456      | 2012-05-01 00:00:00 | 123                 |
    When I am on bar.gov's search page
    And I fill in "query" with "america"
    And I press "Search"
    Then I should not see "Recent tweet for america (@USASearch)"

    When I go to the affiliate admin page with "bar.gov" selected
    And I follow "Results module"
    Then I should see "Recent Tweets"

    When I check "Is twitter govbox enabled"
    And I press "Save"
    When I go to bar.gov's search page
    And I fill in "query" with "america"
    And I press "Search"
    Then I should see "Recent tweet for america (@USASearch)"
    
  Scenario: When there are relevant Flickr photos for a search
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | contact_name | locale | is_photo_govbox_enabled   |
      | bar site         | bar.gov    | aff@bar.gov   | John Bar     | en     | true                      |
    And the following FlickrPhotos exist:
      | title     | description             | url_sq                         | owner | flickr_id | affiliate_name  |
      | AMERICA   | A picture of our nation | http://www.flickr.com/someurl | 123   | 456       | bar.gov         |
    When I am on bar.gov's search page
    And I fill in "query" with "america"
    And I press "Search"
    Then I should see "Photos of 'america' by bar site"
    
    When I fill in "query" with "obama"
    And I press "Search"
    Then I should not see "Photos of 'america' by bar site"
  
