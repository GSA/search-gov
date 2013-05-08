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
      | link                             | title               | guid       | published_ago | multiplier | published_at | description                                | contributor   | publisher    | subject        |
      | http://www.whitehouse.gov/news/1 | First <b> item </b> | pressuuid1 | day           | 1          |              | <i> item </i> First news item for the feed | president     | briefingroom | economy        |
      | http://www.whitehouse.gov/news/2 | Second item         | pressuuid2 | day           | 1          |              | item Next news item for the feed           | vicepresident | westwing     | jobs           |
      | http://www.whitehouse.gov/news/9 | stale first item    | pressuuid9 | months        | 14         |              | item first Stale news item                 | vicepresident | westwing     | jobs           |
      | http://www.whitehouse.gov/news/3 | Third item          | pressuuid3 |               | 1          | 2012-10-01   | item Next news item for the feed           | firstlady     | newsroom     | health         |
      | http://www.whitehouse.gov/news/4 | Fourth item         | pressuuid4 |               | 1          | 2012-10-17   | item Next news item for the feed           | president     | newsroom     | foreign policy |
    And feed "Photo Gallery" has the following news items:
      | link                             | title       | guid  | published_ago | description                       |
      | http://www.whitehouse.gov/news/3 | Third item  | uuid3 | week          | item More news items for the feed |
      | http://www.whitehouse.gov/news/4 | Fourth item | uuid4 | week          | item Last news item for the feed  |
    And feed "Videos" has the following news items:
      | link                                       | title             | guid       |  multiplier    | published_ago | description                              | contributor | publisher | subject   |
      | http://www.youtube.com/watch?v=0hLMc-6ocRk | First video item  | videouuid5 |        14      | months        | item First video news item for the feed  | firstlady   | westwing  | exercise  |
      | http://www.youtube.com/watch?v=R2RWscJM97U | Second video item | videouuid6 |        1       | day           | item Second video news item for the feed | president   | memoranda | elections |
    And feed "Hide Me" has the following news items:
      | link                                    | title             | guid        | published_ago | description                    |
      | http://www.whitehouse.gov/news/hidden/1 | First hidden item | hiddenuuid1 | week          | First hidden news for the feed |
    And feed "Noticias" has the following news items:
      | link                              | title               | guid    | published_ago | published_at | description                                | subject        |
      | http://www.gobiernousa.gov/news/1 | First Spanish item  | esuuid1 | day           |              | Gobierno item First news item for the feed | economy        |
      | http://www.gobiernousa.gov/news/2 | Second Spanish item | esuuid2 | day           |              | Gobierno item Next news item for the feed  | jobs           |
      | http://www.gobiernousa.gov/news/3 | Third Spanish item  | esuuid3 | day           |              | Gobierno item Next news item for the feed  | health         |
      | http://www.gobiernousa.gov/news/4 | Fourth Spanish item | esuuid4 | day           |              | Gobierno item Next news item for the feed  | foreign policy |
      | http://www.gobiernousa.gov/news/5 | Fifth Spanish item  | esuuid5 | day           | 2012-10-1    | Gobierno item Next news item for the feed  | education      |
      | http://www.gobiernousa.gov/news/6 | Sixth Spanish item  | esuuid6 | day           | 2012-10-17   | Gobierno item Next news item for the feed  | olympics       |
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
    And I should not see "stale"
    And I should see "First <b> item </b>" in the rss feed govbox
    And I should not see "First video item" in the rss feed govbox
    And I should see "Videos of 'first item' by bar site"
    And I should see "First video item" in the video rss feed govbox
    And I should see an image with alt text "First video item"
    And I should see an image with src "http://i.ytimg.com/vi/0hLMc-6ocRk/2.jpg"
    And I should not see "First item" in the video rss feed govbox
    And I should not see "First hidden item"
    And I should not see "Show Options" in the left column
    And I should not see "Hide Options" in the left column

    When I follow "News for 'first item'"
    Then I should be on the news search page
    And I should have the following query string:
      |affiliate|bar.gov   |
      |query    |first item|
      |m        |false     |
    And I should see "Show Options" in the left column
    And I should see "Hide Options" in the left column
    And I should see "First <b> item </b>"
    And I should see "i> item </i> First news item for the feed"
    And I should see "First video item"
    And I should see a link to "Advanced Search" in the advanced search section

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
    When I follow "Last year" in the results filters
    And I fill in "query" with "second item"
    And I press "Search"
    Then I should see "Videos" in the left column
    And I should not see a link to "Videos"
    And I should see "Second video item"
    And I should not see "Second item"

    When I am on bar.gov's search page
    And I fill in "query" with "loren"
    And I press "Search"
    Then I should not see "News for 'loren' from bar site"

    When there are 30 video news items for "Videos"
    And I am on bar.gov's search page
    And I follow "Videos"
    Then I should see "32 results"
    And I should see 21 video news results

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
    And I should see 21 video news results
    And I should see an image with src "http://i.ytimg.com/vi/R2RWscJM97U/2.jpg"
    And I should see yesterday's date in the English search results

    When I am on bar.gov's news search page
    And I fill in "query" with "item"
    And I press "Search"
    And I follow "Photo Gallery"
    And I follow "Last hour"
    Then I should see "no results found for 'item'"

    When I follow "Everything" in the left column
    Then I should not see a link to "Everything" in the left column

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
    And I should not see "Mostrar opciones" in the left column
    And I should not see "Ocultar opciones" in the left column
    And I should not see "Cualquier fecha"
    And I should not see "All Time"
    And I should see "Noticias sobre de 'gobierno' de Spanish bar site"
    And I should see "Videos de 'gobierno' de Spanish bar site"

    When I follow "Noticias sobre de 'gobierno'"
    Then I should see "Mostrar opciones" in the left column
    And I should see "Ocultar opciones" in the left column
    And I should see "Spanish item"
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
    Then I should see 2 video news results
    And I should see an image with alt text "First Spanish video item"
    And I should see an image with src "http://i.ytimg.com/vi/EqExXXahb0s/2.jpg"
    And I should see yesterday's date in the Spanish search results

  Scenario: Searching news items using time filters
    Given the following Affiliates exist:
      | display_name                 | name       | contact_email | contact_name | locale |
      | bar site                     | bar.gov    | aff@bar.gov   | John Bar     | en     |
      | Spanish bar site             | es.bar.gov | aff@bar.gov   | John Bar     | es     |
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                                                  | is_navigable | shown_in_govbox |
      | Press         | http://www.whitehouse.gov/feed/press                                 | true         | true            |
      | Photo Gallery | http://www.whitehouse.gov/feed/media/photo-gallery                   | true         | true            |
      | Videos        | http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse | true         | true            |
      | Hide Me       | http://www.whitehouse.gov/feed/media/photo-gallery                   | false        | false           |
    And affiliate "es.bar.gov" has the following RSS feeds:
      | name                  | url                                                                    | is_navigable | shown_in_govbox |
      | Noticias              | http://www.usa.gov/gobiernousa/rss/actualizaciones-articulos.xml       | true         | true            |
      | Spanish Photo Gallery | http://www.whitehouse.gov/feed/media/photo-gallery                     | true         | true            |
      | Spanish Videos        | http://gdata.youtube.com/feeds/base/videos?alt=rss&author=eswhitehouse | true         | true            |
    And feed "Press" has the following news items:
      | link                             | title       | guid       | published_ago | published_at | description                       | contributor   | publisher    | subject        |
      | http://www.whitehouse.gov/news/1 | First item  | pressuuid1 | day           |              | item First news item for the feed | president     | briefingroom | economy        |
      | http://www.whitehouse.gov/news/2 | Second item | pressuuid2 | day           |              | item Next news item for the feed  | vicepresident | westwing     | jobs           |
      | http://www.whitehouse.gov/news/3 | Third item  | pressuuid3 |               | 2012-10-01   | item Next news item for the feed  | firstlady     | newsroom     | health         |
      | http://www.whitehouse.gov/news/4 | Fourth item | pressuuid4 |               | 2012-10-17   | item Next news item for the feed  | president     | newsroom     | foreign policy |
    And feed "Photo Gallery" has the following news items:
      | link                             | title       | guid  | published_ago | description                       |
      | http://www.whitehouse.gov/news/3 | Third item  | uuid3 | week          | item More news items for the feed |
      | http://www.whitehouse.gov/news/4 | Fourth item | uuid4 | week          | item Last news item for the feed  |
    And feed "Videos" has the following news items:
      | link                                       | title             | guid       | published_ago | description                              | contributor | publisher | subject   |
      | http://www.youtube.com/watch?v=0hLMc-6ocRk | First video item  | videouuid5 | day           | item First video news item for the feed  | firstlady   | westwing  | exercise  |
      | http://www.youtube.com/watch?v=R2RWscJM97U | Second video item | videouuid6 | day           | item Second video news item for the feed | president   | memoranda | elections |
    And feed "Hide Me" has the following news items:
      | link                                    | title             | guid        | published_ago | description                    |
      | http://www.whitehouse.gov/news/hidden/1 | First hidden item | hiddenuuid1 | week          | First hidden news for the feed |
    And feed "Noticias" has the following news items:
      | link                              | title               | guid    | published_ago | published_at | description                                | subject        |
      | http://www.gobiernousa.gov/news/1 | First Spanish item  | esuuid1 | day           |              | Gobierno item First news item for the feed | economy        |
      | http://www.gobiernousa.gov/news/2 | Second Spanish item | esuuid2 | day           |              | Gobierno item Next news item for the feed  | jobs           |
      | http://www.gobiernousa.gov/news/3 | Third Spanish item  | esuuid3 | day           |              | Gobierno item Next news item for the feed  | health         |
      | http://www.gobiernousa.gov/news/4 | Fourth Spanish item | esuuid4 | day           |              | Gobierno item Next news item for the feed  | foreign policy |
      | http://www.gobiernousa.gov/news/5 | Fifth Spanish item  | esuuid5 | day           | 2012-10-1    | Gobierno item Next news item for the feed  | education      |
      | http://www.gobiernousa.gov/news/6 | Sixth Spanish item  | esuuid6 | day           | 2012-10-17   | Gobierno item Next news item for the feed  | olympics       |
    And feed "Spanish Photo Gallery" has the following news items:
      | link                             | title       | guid    | published_ago | description                       |
      | http://www.whitehouse.gov/news/3 | Third item  | esuuid7 | week          | item More news items for the feed |
      | http://www.whitehouse.gov/news/4 | Fourth item | esuuid8 | week          | item Last news item for the feed  |
    And feed "Spanish Videos" has the following news items:
      | link                                       | title                     | guid     | published_ago | description                           |
      | http://www.youtube.com/watch?v=EqExXXahb0s | First Spanish video item  | esvuuid1 | day           | Gobierno video news item for the feed |
      | http://www.youtube.com/watch?v=C5WWyZ0cTcM | Second Spanish video item | esvuuid2 | day           | Gobierno video news item for the feed |
    And the following SAYT Suggestions exist for bar.gov:
      | phrase           |
      | Some Unique item |
      | el paso term     |
    When I am on bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search" in the search box
    And I follow "Press"
    Then I should see "All Time" in the results filters
    And I should not see a link to "All Time" in the results filters
    And the "From:" field should be blank
    And the "To:" field should be blank
    And I should see "Most recent" in the selected sort filter
    And I should not see a link to "Most recent" in the results filters
    And I should see a link to "Best match" in the results filters
    When I follow "Last week"
    Then I should see a link to "All Time" in the results filters
    And the "From:" field should be blank
    And the "To:" field should be blank
    And I should see the browser page titled "item - bar site Search Results"
    And I should see "item First news item for the feed"
    And I should see "item Next news item for the feed"
    And I should not see "item More news items for the feed"
    And I should not see "item Last news item for the feed"
    When I follow "Best match"
    Then I should see "Best match" in the selected sort filter
    And I should not see a link to "Best match" in the results filters
    And I should see a link to "Most recent" in the results filters
    When I follow "Most recent"
    Then I should see "Most recent" in the selected sort filter
    And I should not see a link to "Most recent" in the results filters
    And I should see a link to "Best match" in the results filters
    When I follow "Last year" in the results filters
    And I follow "Everything" in the left column
    Then I should see the browser page titled "item - bar site Search Results"
    And I should see "Last year" in the search results section
    And I should not see a link to "Last year" in the search results section

    When I am on bar.gov's search page
    And I follow "Press"
    Then I should see "Custom range"
    When I fill in "From:" with "9/30/2012"
    And I fill in "To:" with "10/15/2012"
    And I press "Search" in the results filters
    Then I should see "Sep 30, 2012 - Oct 15, 2012" in the results filters
    And the "From:" field should contain "9/30/2012"
    And the "To:" field should contain "10/15/2012"
    And I should see a link to "Third item" with url for "http://www.whitehouse.gov/news/3"
    And I should not see a link to "Fourth item"

    When I fill in "query" with "item"
    And I press "Search" in the search box
    And the "From:" field should contain "9/30/2012"
    And the "To:" field should contain "10/15/2012"
    And I should see a link to "Third item" with url for "http://www.whitehouse.gov/news/3"
    And I should not see a link to "Fourth item"

    When I follow "All Time" in the results filters
    Then the "From:" field should be blank
    And the "To:" field should be blank

    When I am on bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search"
    And I follow "Press"
    And I fill in "From:" with "9/30/2012"
    And I fill in "To:" with "10/15/2012"
    And I press "Search" in the results filters
    And I follow "Everything"
    And I should see the browser page titled "item - bar site Search Results"
    And I should see "Custom range" in the selected time filter
    And the "From:" field should contain "9/30/2012"
    And the "To:" field should contain "10/15/2012"

    When I am on bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search"
    And I follow "Press"
    And I fill in "From:" with "9/30/2012"
    And I fill in "To:" with "10/15/2012"
    And I press "Search" in the results filters
    And I follow "Last year"
    Then I should see "Last year" in the selected time filter

    When I am on es.bar.gov's search page
    And I fill in "query" with "item"
    And I press "Buscar" in the search box
    And I follow "Noticias"
    Then I should see "Cualquier fecha" in the selected time filter
    And I should not see a link to "Cualquier fecha" in the results filters
    And the "Desde:" field should be blank
    And the "Hasta:" field should be blank
    And I should see "Más recientes" in the selected sort filter
    And I should not see a link to "Más recientes" in the results filters
    And I should see a link to "Más relevantes" in the results filters
    When I follow "Más relevantes"
    Then I should see "Más relevantes" in the selected sort filter
    And I should not see a link to "Más relevantes" in the results filters
    And I should see a link to "Más recientes" in the results filters
    When I follow "Más recientes"
    Then I should see "Más recientes" in the selected sort filter
    And I should not see a link to "Más recientes" in the results filters
    And I should see a link to "Más relevantes" in the results filters
    When I follow "Última semana"
    Then I should see a link to "Cualquier fecha" in the results filters
    And the "Desde:" field should be blank
    And the "Hasta:" field should be blank
    And I should see the browser page titled "item - Spanish bar site resultados de la búsqueda"
    And I should see "item First news item for the feed"
    And I should see "item Next news item for the feed"
    And I should not see "item More news items for the feed"
    And I should not see "item Last news item for the feed"
    When I follow "Último año" in the results filters
    And I follow "Todo" in the left column
    Then I should see the browser page titled "item - Spanish bar site resultados de la búsqueda"
    And I should see "Último año" in the selected time filter
    And I should not see a link to "Último año" in the results filters

    When I am on es.bar.gov's search page
    And I follow "Noticias"
    Then I should see "Elija las fechas"
    When I fill in "Desde:" with "30/9/2012"
    And I fill in "Hasta:" with "15/10/2012"
    And I press "Buscar" in the results filters
    Then the "Desde:" field should contain "30/9/2012"
    And the "Hasta:" field should contain "15/10/2012"
    And I should see a link to "Fifth Spanish item" with url for "http://www.gobiernousa.gov/news/5"
    And I should not see a link to "Sixth Spanish item"

    When I fill in "query" with "item"
    And I press "Buscar" in the search box
    Then the "Desde:" field should contain "30/9/2012"
    And the "Hasta:" field should contain "15/10/2012"
    And I should see a link to "Fifth Spanish item" with url for "http://www.gobiernousa.gov/news/5"
    And I should not see a link to "Sixth Spanish item"

  Scenario: Searching news items with default dublin core mappings
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | contact_name | locale |
      | bar site         | en.bar.gov | aff@bar.gov   | John Bar     | en     |
      | Spanish bar site | es.bar.gov | aff@bar.gov   | John Bar     | es     |
    And affiliate "en.bar.gov" has the following RSS feeds:
      | name          | url                                                                  | is_navigable | shown_in_govbox |
      | Press         | http://www.whitehouse.gov/feed/press                                 | true         | true            |
      | Videos        | http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse | true         | true            |
    And affiliate "es.bar.gov" has the following RSS feeds:
      | name           | url                                                                    | is_navigable | shown_in_govbox |
      | Noticias       | http://www.usa.gov/gobiernousa/rss/actualizaciones-articulos.xml       | true         | true            |
      | Spanish Videos | http://gdata.youtube.com/feeds/base/videos?alt=rss&author=eswhitehouse | true         | true            |
    And feed "Press" has the following news items:
      | link                             | title       | guid       | published_ago | published_at | description                       | contributor | publisher    | subject        |
      | http://www.whitehouse.gov/news/1 | First item  | pressuuid1 | day           |              | item First news item for the feed | president   | briefingroom | economy        |
      | http://www.whitehouse.gov/news/2 | Second item | pressuuid2 | day           |              | item Next news item for the feed  | president   | westwing     | jobs           |
      | http://www.whitehouse.gov/news/3 | Third item  | pressuuid3 |               | 2012-10-01   | item Next news item for the feed  | firstlady   | newsroom     | health         |
      | http://www.whitehouse.gov/news/4 | Fourth item | pressuuid4 |               | 2012-10-17   | item Next news item for the feed  | president   | speeches     | foreign policy |
      | http://www.whitehouse.gov/news/5 | Fifth item  | pressuuid5 |               | 2012-10-17   | item Next news item for the feed  | president   | remarks      | foreign policy |
      | http://www.whitehouse.gov/news/6 | Sixth item  | pressuuid6 |               | 2012-10-17   | item Next news item for the feed  | president   | statements   | foreign policy |
    And feed "Videos" has the following news items:
      | link                                       | title             | guid       | published_ago | description                              | contributor | publisher | subject   |
      | http://www.youtube.com/watch?v=0hLMc-6ocRk | First video item  | videouuid5 | day           | item First video news item for the feed  | firstlady   | westwing  | exercise  |
      | http://www.youtube.com/watch?v=R2RWscJM97U | Second video item | videouuid6 | day           | item Second video news item for the feed | president   | memoranda | elections |
    And feed "Noticias" has the following news items:
      | link                              | title               | guid    | published_ago | published_at | description                                | contributor | publisher    | subject        |
      | http://www.gobiernousa.gov/news/1 | First Spanish item  | esuuid1 | day           |              | Gobierno item First news item for the feed | president   | briefingroom | economy        |
      | http://www.gobiernousa.gov/news/2 | Second Spanish item | esuuid2 | day           |              | Gobierno item Next news item for the feed  | president   | westwing     | jobs           |
      | http://www.gobiernousa.gov/news/3 | Third Spanish item  | esuuid3 | day           | 2012-10-01   | Gobierno item Next news item for the feed  | firstlady   | newsroom     | health         |
      | http://www.gobiernousa.gov/news/4 | Fourth Spanish item | esuuid4 | day           | 2012-10-17   | Gobierno item Next news item for the feed  | president   | speeches     | foreign policy |
      | http://www.gobiernousa.gov/news/5 | Fifth Spanish item  | esuuid5 | day           | 2012-10-17   | Gobierno item Next news item for the feed  | president   | remarks      | foreign policy |
      | http://www.gobiernousa.gov/news/6 | Sixth Spanish item  | esuuid6 | day           | 2012-10-17   | Gobierno item Next news item for the feed  | president   | statements   | foreign policy |
    And feed "Spanish Videos" has the following news items:
      | link                                       | title                     | guid     | published_ago | description                           | contributor | publisher | subject   |
      | http://www.youtube.com/watch?v=EqExXXahb0s | First Spanish video item  | esvuuid1 | day           | Gobierno video news item for the feed | firstlady   | westwing  | exercise  |
      | http://www.youtube.com/watch?v=C5WWyZ0cTcM | Second Spanish video item | esvuuid2 | day           | Gobierno video news item for the feed | president   | memoranda | elections |
    When I am on en.bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search"
    And I follow "Press"
    Then I should not see the left column options expanded
    And I should see "All contributors" in the selected contributor facet selector
    And I should not see a link to "All contributors" in the contributor facet selector
    And I should not see collapsible facet value in the contributor facet selector
    And I should see "All subjects" in the selected subject facet selector
    And I should not see a link to "All subjects" in the subject facet selector
    And I should not see collapsible facet value in the subject facet selector
    And I should see "All publishers" in the selected publisher facet selector
    And I should not see a link to "All publishers" in the publisher facet selector
    And I should see 2 collapsible facet values in the publisher facet selector
    And I should see "More" in the left column

    When I follow "president" in the left column
    Then I should see a link to "All contributors" in the left column
    And I should see "president" in the left column
    And I should not see a link to "president" in the left column
    And I should see "All subjects" in the left column
    And I should not see a link to "All subjects" in the left column
    And I should see "All publishers" in the left column
    And I should not see a link to "All publishers" in the left column
    And I should see "First item"
    And I should see "Second item"
    And I should see "Fourth item"
    And I should not see "Third item"

    When I fill in "From:" with "10/15/2012"
    And I fill in "To:" with "10/31/2012"
    And I press "Search" in the results filters
    Then the "From:" field should contain "10/15/2012"
    And the "To:" field should contain "10/31/2012"
    And I should see "president" in the left column
    And I should not see a link to "president" in the left column
    And I should see "Fourth item"
    And I should not see "First item"
    And I should not see "Second item"
    And I should not see "Third item"

    When I follow "foreign policy" in the left column
    Then the "From:" field should contain "10/15/2012"
    And the "To:" field should contain "10/31/2012"
    And I should see a link to "All contributors" in the left column
    And I should see "president" in the left column
    And I should not see a link to "president" in the left column
    And I should see a link to "All subjects" in the left column
    And I should see "foreign policy" in the left column
    And I should not see a link to "foreign policy" in the left column
    And I should see "All publishers" in the left column
    And I should not see a link to "All publishers" in the left column
    And I should see "Fourth item"
    And I should not see "First item"
    And I should not see "Second item"
    And I should not see "Third item"

    When I follow "remarks" in the left column
    Then the "From:" field should contain "10/15/2012"
    And the "To:" field should contain "10/31/2012"
    And I should see a link to "All contributors" in the left column
    And I should see "president" in the left column
    And I should not see a link to "president" in the left column
    And I should see a link to "All subjects" in the left column
    And I should see "foreign policy" in the left column
    And I should not see a link to "foreign policy" in the left column
    And I should see a link to "All publishers" in the left column
    And I should see "remarks" in the left column
    And I should not see a link to "remarks" in the left column
    And I should see "Fifth item"
    And I should not see "Fourth item"
    And I should not see "Sixth item"

    When I follow "Clear" in the results filters
    Then I should not see the left column options expanded
    And I should not see a link to "All contributors" in the contributor facet selector
    And I should not see a link to "All publishers" in the left column
    And I should not see a link to "All subjects" in the left column

    When I am on es.bar.gov's search page
    And I fill in "query" with "item"
    And I press "Buscar"
    And I follow "Noticias"
    Then I should not see the left column options expanded
    And I should see "Cualquier colaborador" in the left column
    And I should not see a link to "Cualquier colaborador" in the left column
    And I should not see collapsible facet value in the contributor facet selector
    And I should see "Cualquier tema" in the left column
    And I should not see a link to "Cualquier tema" in the left column
    And I should see "Cualquier editor" in the left column
    And I should not see collapsible facet value in the subject facet selector
    And I should not see a link to "Cualquier editor" in the left column
    And I should see 2 collapsible facet values in the publisher facet selector
    And I should see "Más" in the left column

    When I follow "president" in the left column
    Then I should see a link to "Cualquier colaborador" in the left column
    And I should see "president" in the left column
    And I should not see a link to "president" in the left column
    And I should see "Cualquier tema" in the left column
    And I should not see a link to "Cualquier tema" in the left column
    And I should see "Cualquier editor" in the left column
    And I should not see a link to "Cualquier editor" in the left column
    And I should see "First Spanish item"
    And I should see "Second Spanish item"
    And I should see "Fourth Spanish item"
    And I should not see "Third Spanish item"

    When I fill in "Desde:" with "15/10/2012"
    And I fill in "Hasta:" with "31/10/2012"
    And I press "Buscar" in the results filters
    Then the "Desde:" field should contain "15/10/2012"
    And the "Hasta:" field should contain "31/10/2012"
    And I should see "president" in the left column
    And I should not see a link to "president" in the left column
    And I should see "Fourth Spanish item"
    And I should not see "First Spanish item"
    And I should not see "Second Spanish item"
    And I should not see "Third Spanish item"

    When I follow "foreign policy" in the left column
    Then the "Desde:" field should contain "15/10/2012"
    And the "Hasta:" field should contain "31/10/2012"
    Then I should see a link to "Cualquier colaborador" in the left column
    And I should see "president" in the left column
    And I should not see a link to "president" in the left column
    And I should see a link to "Cualquier tema" in the left column
    And I should see "foreign policy" in the left column
    And I should not see a link to "foreign policy" in the left column
    And I should see "Cualquier editor" in the left column
    And I should not see a link to "Cualquier editor" in the left column
    And I should see "Fourth Spanish item"
    And I should not see "First Spanish item"
    And I should not see "Second Spanish item"
    And I should not see "Third Spanish item"

    When I follow "remarks" in the left column
    Then the "Desde:" field should contain "15/10/2012"
    And the "Hasta:" field should contain "31/10/2012"
    And I should see a link to "Cualquier colaborador" in the left column
    And I should see "president" in the left column
    And I should not see a link to "president" in the left column
    And I should see a link to "Cualquier tema" in the left column
    And I should see "foreign policy" in the left column
    And I should not see a link to "foreign policy" in the left column
    And I should see a link to "Cualquier editor" in the left column
    And I should see "remarks" in the left column
    And I should not see a link to "remarks" in the left column
    And I should see "Fifth Spanish item"
    And I should not see "Fourth Spanish item"
    And I should not see "Sixth Spanish item"

  Scenario: Searching news items with custom dublin core mappings
    Given the following Affiliates exist:
      | display_name | name       | contact_email | contact_name | locale | dublin_core_mappings                                                                                 |
      | bar site     | en.bar.gov | aff@bar.gov   | John Bar     | en     | {:contributor=>'Administration Official',:publisher => 'Briefing Room Section', :subject => 'Issue'} |
    And affiliate "en.bar.gov" has the following RSS feeds:
      | name  | url                                  | is_navigable | shown_in_govbox |
      | Press | http://www.whitehouse.gov/feed/press | true         | true            |
    And feed "Press" has the following news items:
      | link                             | title       | guid       | published_ago | published_at | description                       | contributor | publisher    | subject        |
      | http://www.whitehouse.gov/news/1 | First item  | pressuuid1 | day           |              | item First news item for the feed | president   | briefingroom | economy        |
      | http://www.whitehouse.gov/news/2 | Second item | pressuuid2 | day           |              | item Next news item for the feed  | president   | westwing     | jobs           |
      | http://www.whitehouse.gov/news/3 | Third item  | pressuuid3 |               | 2012-10-01   | item Next news item for the feed  | firstlady   | newsroom     | health         |
      | http://www.whitehouse.gov/news/4 | Fourth item | pressuuid4 |               | 2012-10-17   | item Next news item for the feed  | president   | speeches     | foreign policy |
    When I am on en.bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search"
    And I follow "Press"
    Then I should not see the left column options expanded
    And I should see "Administration Official" in the left column
    And I should not see a link to "Administration Official" in the left column
    And I should see "Issue" in the left column
    And I should not see a link to "Issue" in the left column
    And I should see "Briefing Room Section" in the left column
    And I should not see a link to "Briefing Room Section" in the left column

  Scenario: Searching a domain with Bing results that match a specific news item
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains             |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | usasearch.howto.gov |
    And affiliate "bar.gov" has the following RSS feeds:
      | name      | url                                 | is_navigable | shown_in_govbox |
      | All Posts | http://usasearch.howto.gov/all.atom | true         | false           |
    And feed "All Posts" has the following news items:
      | link                                                | title      | guid  | published_ago | description                       |
      | http://usasearch.howto.gov/help-desk | First item | uuid1 | day           | item First news item for the feed |
    When I am on bar.gov's search page
    And I fill in "query" with "social media"
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
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | howto.gov |
    When I am on bar.gov's search page
    And I fill in "query" with "Helping agencies deliver a great customer experience"
    And I press "Search"
    Then I should see "howto.gov"
    And I should not see "HowTo.gov" in bold font

    When I fill in "query" with "howto.gov"
    And I press "Search"
    Then I should see "HowTo.gov" in bold font

  Scenario: Filtering indexed documents when they are duplicated in Bing search results
    Given the following Affiliates exist:
      | display_name | name       | contact_email  | contact_name |
      | agency site  | agency.gov | aff@agency.gov | John Bar     |
    And the following site domains exist for the affiliate agency.gov:
      | domain         | site_name      |
      | usa.gov        | Agency Website |
    And the following IndexedDocuments exist:
      | title        | description                                                                         | url                 | affiliate  | last_crawl_status |
      | USA.gov Blog | We help you find official U.S. government information and services on the Internet. | http://blog.usa.gov/A4C32FAE6F3DB386FC32ED1C4F3024742ED30906 | agency.gov | OK                |
    When I am on agency.gov's search page
    And I fill in "query" with "usa.gov blog"
    And I press "Search"
    Then I should not see "See more document results"

  Scenario: Searching within an agency on English SERP
    Given the following Affiliates exist:
      | display_name    | name        | contact_email | contact_name | domains | search_results_page_title                      | is_agency_govbox_enabled | locale |
      | USA.gov         | usagov      | aff@bar.gov   | John Bar     | .gov    | {Query} - {SiteName} Search Results            | true                     | en     |
      | GobiernoUSA.gov | gobiernousa | aff@bar.gov   | John Bar     | .gov    | {Query} - {SiteName} resultados de la búsqueda | true                     | es     |
    And the following Agency entries exist:
      | name | domain  |
      | TSA  | tsa.gov |
    And the following Agency Urls exist:
      | name | locale | url                         |
      | TSA  | en     | http://tsa.gov/             |
      | TSA  | en     | http://www.tsa.gov/         |
      | TSA  | es     | http://www.tsa.gov/espanol/ |
    When I am on usagov's search page
    And I fill in "query" with "tsa"
    And I press "Search"
    Then I should see the agency govbox
    When I fill in "query" with "benefits" in the agency govbox
    And I press "Search" in the agency govbox
    Then I should see the browser page titled "benefits - USA.gov Search Results"
    And the "query" field should contain "benefits"
    And I should see "We're including results for 'benefits' from only tsa.gov."

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
      | medline_title | medline_tid | url                                                                          |
      | Hippo1        | 24680       | http://www.nlm.nih.gov/medlineplus/Hippopotomonstrosesquippedaliophobia.html |
    When I am on english-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search"
    Then I should see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears" in the medline govbox
    And I should see a link to "Hippo1" with url for "http://www.nlm.nih.gov/medlineplus/Hippopotomonstrosesquippedaliophobia.html"

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
      | display_name | name       | contact_email | contact_name | locale | is_twitter_govbox_enabled |
      | bar site     | bar.gov    | aff@bar.gov   | John Bar     | en     | true                      |
      | spanish site | es.bar.gov | aff@bar.gov   | John Bar     | es     | true                      |
    And the following Twitter Profiles exist:
      | screen_name | name            | twitter_id | affiliate  |
      | USASearch   | USASearch.gov   | 123        | bar.gov    |
      | GobiernoUSA | GobiernoUSA.gov | 456        | es.bar.gov |
    And the following Tweets exist:
      | tweet_text                     | tweet_id | published_ago | twitter_profile_id | url                  | expanded_url                 | display_url           |
      | Winter season is great!        | 123456   | hour          | 123                |                      |                              |                       |
      | Summer season is great!        | 234567   | year          | 123                |                      |                              |                       |
      | Spring season is great!        | 456789   | hour          | 123                |                      |                              |                       |
      | Ok season http://t.co/YQQSs9bb | 184957   | hour          | 123                | http://t.co/YQQSs9bb | http://tmblr.co/Z8xAVxUEKvaK | tmblr.co/Z8xAVxUEK... |
      | Estados Unidos es grande!      | 789012   | hour          | 456                |                      |                              |                       |
    When I am on bar.gov's search page
    And I fill in "query" with "season"
    And I press "Search"
    Then I should see "Recent tweets for 'season' by bar site"
    And I should see a link to "USASearch.gov" with url for "http://twitter.com/USASearch"
    And I should see "USASearch.gov @USASearch"
    And I should see "Winter season is great!"
    And I should see "Spring season is great!"
    And I should see a link to "http://t.co/YQQSs9bb" with text "tmblr.co/Z8xAVxUEK..."
    And I should see "season" in bold font
    And I should not see "Summer season is great!"

    When I am on es.bar.gov's search page
    And I fill in "query" with "Estados Unidos"
    And I press "Buscar"
    Then I should see "Tweet más reciente para 'Estados Unidos' de spanish site"
    And I should see a link to "GobiernoUSA.gov" with url for "http://twitter.com/GobiernoUSA"
    And I should see "GobiernoUSA.gov @GobiernoUSA"
    And I should see "Estados Unidos es grande!"
    And I should see "Estados Unidos" in bold font

  Scenario: Enabling and disabling the Twitter govbox
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | contact_name | locale |
      | bar site         | bar.gov    | aff@bar.gov   | John Bar     | en     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "bar.gov" selected
    And I follow "Results modules"
    Then I should not see "Recent Tweets"

    Given the following Twitter Profiles exist:
      | screen_name | twitter_id | affiliate |
      | USASearch   | 123        | bar.gov   |
    And the following Tweets exist:
      | tweet_text          | tweet_id    | published_ago        | twitter_profile_id  |
      | AMERICA is great!   | 123456      | hour                 | 123                 |
    When I am on bar.gov's search page
    And I fill in "query" with "america"
    And I press "Search"
    Then I should not see "Recent tweet for america"

    When I go to the affiliate admin page with "bar.gov" selected
    And I follow "Results module"
    Then I should see "Recent Tweets"

    When I check "Is twitter govbox enabled"
    And I press "Save"
    When I go to bar.gov's search page
    And I fill in "query" with "america"
    And I press "Search"
    Then I should see "Recent tweet for 'america' by bar site"

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

  Scenario: Enabling and disabling Flickr photos
    Given the following Affiliates exist:
      | display_name     | name       | contact_email | contact_name | locale | is_photo_govbox_enabled   |
      | bar site         | bar.gov    | aff@bar.gov   | John Bar     | en     | false                     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "bar.gov" selected
    And I follow "Results modules"
    Then I should not see "Photos"

    Given the following FlickrPhotos exist:
      | title     | description             | url_sq                        | owner | flickr_id | affiliate_name  |
      | AMERICA   | A picture of our nation | http://www.flickr.com/someurl | 123   | 456       | bar.gov         |
    When I am on bar.gov's search page
    And I fill in "query" with "america"
    And I press "Search"
    Then I should not see "Photos of 'america' by bar site"

    When I go to the affiliate admin page with "bar.gov" selected
    And I follow "Results module"
    Then I should see "Photos"

    When I check "Is photo govbox enabled"
    And I press "Save"
    When I go to bar.gov's search page
    And I fill in "query" with "america"
    And I press "Search"
    Then I should see "Photos of 'america' by bar site"

  Scenario: When there are forms for a search
    Given the following FormAgencies exist:
      | name      | locale | display_name                              |
      | uscis.gov | en     | U.S. Citizenship and Immigration Services |
      | ssa.gov   | en     | Social Security Administration            |
    And the following Forms exist for en uscis.gov form agency:
      | number             | url                                           | file_type | title                                                        | description                                                                          | file_size | number_of_pages | landing_page_url               | revision_date | expiration_date |
      | I-485              | http://www.uscis.gov/files/form/i-485.pdf     | PDF       | Application to Register Permanent Residence or Adjust Status | To apply to adjust your status to that of a permanent resident of the United States. | 272KB     | 1               | http://www.uscis.gov/i-485     | 8/7/09        | 2013-01-31      |
      | I-485 Supplement A | http://www.uscis.gov/files/form/i-485supa.pdf | PDF       | Supplement A to Form I-485                                   | To provide a supplemental information to USCIS                                       | 170KB     | 5               | http://www.uscis.gov/i-485supa | 1/18/11       |                 |
    And the following Links exist for en uscis.gov form I-485:
      | title                                                          | url                                            | file_size | file_type |
      | Instructions for Form I-485                                    | http://www.uscis.gov/files/form/i-485instr.pdf | 253KB     | PDF       |
      | Form G-1145, E-Notification of Application/Petition Acceptance | http://www.uscis.gov/files/form/g-1145.pdf     | 1KB       | PDF       |
    And the following Forms exist for en ssa.gov form agency:
      | number | url                                             | file_type | title                                                                   | expiration_date |
      | SSA-44 | http://www.socialsecurity.gov/online/ssa-44.pdf | PDF       | Medicare Income-Related Monthly Adjustment Amount - Life-Changing Event | 2014-07-31      |
    And the following Affiliates exist:
      | display_name | name   | contact_email | contact_name | locale | domains | affiliate_form_agencies |
      | usagov site  | usagov | aff@bar.gov   | John Bar     | en     | .gov    | ssa.gov,uscis.gov       |
    And the following IndexedDocuments exist for en uscis.gov form I-485:
      | title                     | description                 | url                               | affiliate | last_crawl_status |
      | USA.gov: * a doc on I-485 | some odie desc. on I-485    | http://answers.usa.gov/page1.html | usagov    | OK                |
      | not ok doc on I-485       | another odie desc. on I-485 | http://answers.usa.gov/page2.html | usagov    | not OK            |
    When I am on usagov's search page
    And I fill in "query" with "I-485"
    And I press "Search"
    Then I should see a link to "Application to Register Permanent Residence or Adjust Status (I-485)" with url for "http://www.uscis.gov/i-485" in the form govbox
    Then I should see the govbox form number "I-485" in bold font
    And I should see "Revised: 8/7/09" in the form govbox
    And I should see "Expires: 1/31/13" in the form govbox
    And I should see "U.S. Citizenship and Immigration Services" in the form govbox
    And I should see "To apply to adjust your status to that of a permanent resident of the United States." in the form govbox
    And I should see a link to "Form I-485" with url for "http://www.uscis.gov/files/form/i-485.pdf" in the form govbox
    And I should see "Form I-485 [PDF, 272KB, 1 page]" in the form govbox
    And I should see a link to "Instructions for Form I-485" with url for "http://www.uscis.gov/files/form/i-485instr.pdf" in the form govbox
    And I should see "Instructions for Form I-485 [PDF, 253KB]" in the form govbox
    And I should see a link to "Form G-1145, E-Notification of Application/Petition Acceptance" with url for "http://www.uscis.gov/files/form/g-1145.pdf" in the form govbox
    And I should see "Form G-1145, E-Notification of Application/Petition Acceptance [PDF, 1KB]" in the form govbox
    And I should see a link to "USA.gov: a doc on I-485" with url for "http://answers.usa.gov/page1.html"
    And I should not see a link to "not ok doc on I-485"

    When I fill in "query" with "supplement A I-485"
    And I press "Search"
    Then I should see a link to "Supplement A to Form I-485" with url for "http://www.uscis.gov/i-485supa" in the form govbox
    And I should see the govbox form number "I-485" in bold font
    And I should see the govbox form number "Supplement" in bold font
    And I should see the govbox form number "A" in bold font
    And I should see the govbox form title "I-485" in bold font
    And I should see the govbox form title "Supplement" in bold font
    And I should see the govbox form title "A" in bold font
    And I should not see the govbox form description "a" in bold font

    When I fill in "query" with "I 485"
    And I press "Search"
    Then I should see a link to "Application to Register Permanent Residence or Adjust Status" with url for "http://www.uscis.gov/i-485" in the form govbox
    When I fill in "query" with "I485"
    And I press "Search"
    Then I should see a link to "Application to Register Permanent Residence or Adjust Status" with url for "http://www.uscis.gov/i-485" in the form govbox

    When I fill in "query" with "SSA-44"
    And I press "Search"
    Then I should see a link to "Medicare Income-Related Monthly Adjustment Amount - Life-Changing Event" with url for "http://www.socialsecurity.gov/online/ssa-44.pdf" in the form govbox
    And I should see the govbox form number "SSA-44" in bold font
    And I should not see "7/31/14" in the form govbox
    And I should see "Form SSA-44 [PDF]"

    When I fill in "query" with "USCIS"
    And I press "Search"
    Then I should not see the form govbox

    When I fill in "query" with "Permanent Residence"
    And I press "Search"
    Then I should not see the form govbox

    When I fill in "query" with "Application to Register Permanent Residence or Adjust Status"
    And I press "Search"
    And I should see the govbox form title "Application to Register Permanent Residence or Adjust Status" in bold font

  Scenario: When using tablet device
    Given I am using a TabletPC device
    And the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     |
    When I am on bar.gov's search page
    And I fill in "query" with "bar"
    And I press "Search"
    Then I should see some Bing search results

  Scenario: Searching document collections
    Given the following Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains        |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     | whitehouse.gov |
    And affiliate "agency.gov" has the following document collections:
      | name      | prefixes                 | is_navigable |
      | Petitions | petitions.whitehouse.gov | true         |
    And the following IndexedDocuments exist:
      | title                   | description                               | url                                             | affiliate  | last_crawled_at | last_crawl_status |
      | First petition article  | This is an article death star petition    | http://petitions.whitehouse.gov/petition-1.html | agency.gov | 11/02/2011      | OK                |
      | Second petition article | This is an article on death star petition | http://petitions.whitehouse.gov/petition-2.html | agency.gov | 11/02/2011      | OK                |
    When I am on agency.gov's search page
    And I follow "Petitions" in the left column
    And I fill in "query" with "'death star'"
    And I press "Search"
    Then I should see a link to "This Isn't the Petition Response You're Looking For | We the ..." with url for "https://petitions.whitehouse.gov/response/isnt-petition-response-youre-looking"
    And I should see a link to "Advanced Search" in the advanced search section
    When I follow "Next"
    Then I should see a link to "First petition article" with url for "http://petitions.whitehouse.gov/petition-1.html"
    And I should see a link to "Second petition article" with url for "http://petitions.whitehouse.gov/petition-2.html"
    And I should not see "Other social media article"

  Scenario: Searching on non navigable document collection
    Given the following Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     | usa.gov |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes            | is_navigable |
      | Blog | http://blog.usa.gov | false        |
      | Web  | http://www.usa.gov  | true         |
    When I am on agency.gov's "Blog" docs search page
    Then I should see "Blog" in the left column
    And I should not see a link to "Everything" in the left column
    And I should not see a link to "Blog" in the left column
    And I should not see a link to "Search Notes" in the left column
    When I fill in "query" with "Noaa"
    And I press "Search"
    Then I should see some Bing search results
    And I should not see a link to "Everything" in the left column
    And I should not see a link to "Blog" in the left column
    And I should not see a link to "Search Notes" in the left column

  Scenario: Searching with malformed query
    Given the following Affiliates exist:
      | display_name | name       | contact_email | contact_name |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     |
    When I am on agency.gov's search page with unsanitized "hello" query
    Then I should see a link to "Images" with sanitized "hello" query

  Scenario: Searching for site specific results using query
    Given the following Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     | usa.gov |
    When I am on agency.gov's search page
    And I fill in "query" with "jobs site:answers.usa.gov"
    And I press "Search"
    Then I should see "answers.usa.gov/"
    And I fill in "query" with "jazz site:wikipedia.org"
    And I press "Search"
    Then I should not see "en.wikipedia.org/wiki/Jazz"

  Scenario: Searching for site specific results using sitelimit
    Given the following Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     | .gov    |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes                         | is_navigable |
      | Blog | http://usasearch.howto.gov/blog/ | true         |
    And affiliate "agency.gov" has the following RSS feeds:
      | name  | url                                                | is_navigable | shown_in_govbox |
      | Press | http://www.whitehouse.gov/feed/press               | true         | false           |
      | Photo | http://www.whitehouse.gov/feed/media/photo-gallery | true         | false           |
    When I am on agency.gov's search page with site limited to "answers.usa.gov"
    And I fill in "query" with "jobs"
    And I press "Search"
    Then I should see "answers.usa.gov/"

    When I follow "Images" in the left column
    And I press "Search"
    And I follow "Everything" in the left column
    Then I should see "answers.usa.gov/"

    When I follow "Blog" in the left column
    And I press "Search"
    And I follow "Everything" in the left column
    Then I should see "answers.usa.gov/"

    When I follow "Press" in the left column
    And I press "Search"
    And I follow "Everything" in the left column
    Then I should see "answers.usa.gov/"

    When I follow "Press" in the left column
    And I fill in "From:" with "1/30/2012"
    And I press "Search" in the results filters
    And I follow "All Time" in the results filters
    And I follow "Everything" in the left column
    Then I should see "answers.usa.gov/"