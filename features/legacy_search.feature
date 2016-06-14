@vcr
Feature: Legacy Search
  In order to get government-related information from specific affiliate agencies
  As a site visitor
  I want to be able to search for information

  Scenario: Search with a blank query on an affiliate page
    Given the following legacy Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    When I am on bar.gov's search page
    And I press "Search" in the legacy search box
    Then I should see "Please enter a search term"

  Scenario: Searching with active RSS feeds
    Given the following legacy Affiliates exist:
      | display_name     | name       | contact_email | contact_name | locale | youtube_handles | is_image_search_navigable |
      | bar site         | bar.gov    | aff@bar.gov   | John Bar     | en     | en_agency       | true                      |
      | Spanish bar site | es.bar.gov | aff@bar.gov   | John Bar     | es     | es_agency       | true                      |
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                                | is_navigable | is_managed |
      | Press         | http://www.whitehouse.gov/feed/press               | true         |            |
      | Photo Gallery | http://www.whitehouse.gov/feed/media/photo-gallery | true         |            |
      | Videos        |                                                    | true         | true       |
      | Hide Me       | http://www.whitehouse.gov/feed/media/hidden        | false        |            |
    And the rss govbox is enabled for the site "bar.gov"
    And affiliate "es.bar.gov" has the following RSS feeds:
      | name           | url                                                              | is_navigable | is_managed |
      | Noticias       | http://www.usa.gov/gobiernousa/rss/actualizaciones-articulos.xml | true         |            |
      | Spanish Videos |                                                                  | true         | true       |
    And the rss govbox is enabled for the site "es.bar.gov"
    And feed "Press" has the following news items:
      | link                             | title               | guid       | published_ago | multiplier | published_at | description                                | contributor   | publisher    | subject        |
      | http://www.whitehouse.gov/news/1 | First <b> item </b> | pressuuid1 | day           | 1          |              | <i> item </i> First news item for the feed | president     | briefingroom | economy        |
      | http://www.whitehouse.gov/news/2 | Second item         | pressuuid2 | day           | 1          |              | item Next news item for the feed           | vicepresident | westwing     | jobs           |
      | http://www.whitehouse.gov/news/9 | stale first item    | pressuuid9 | months        | 14         |              | item first Stale news item                 | vicepresident | westwing     | jobs           |
      | http://www.whitehouse.gov/news/3 | Third item          | pressuuid3 |               | 1          | 2012-10-01   | item Next news item for the feed           | firstlady     | newsroom     | health         |
      | http://www.whitehouse.gov/news/4 | Fourth item         | pressuuid4 |               | 1          | 2012-10-17   | item Next news item for the feed           | president     | newsroom     | foreign policy |
    And feed "Photo Gallery" has the following news items:
      | link                             | title               | guid       | published_ago | description                                |
      | http://www.whitehouse.gov/news/1 | First <b> item </b> | pressuuid1 | week          | <i> item </i> First news item for the feed |
      | http://www.whitehouse.gov/news/3 | Third item          | uuid3      | week          | item More news items for the feed          |
      | http://www.whitehouse.gov/news/4 | Fourth item         | uuid4      | week          | item Last news item for the feed           |
    And feed "en_agency_channel_id" has the following news items:
      | link                                       | title             | guid       |  multiplier    | published_ago | description                              | contributor | publisher | subject   |
      | http://www.youtube.com/watch?v=0hLMc-6ocRk | First video item  | videouuid5 |        12      | months        | item First video news item for the feed  | firstlady   | westwing  | exercise  |
      | http://www.youtube.com/watch?v=R2RWscJM97U | Second video item | videouuid6 |        1       | day           | item Second video news item for the feed | president   | memoranda | elections |
    And feed "Hide Me" has the following news items:
      | link                                    | title             | guid        | published_ago | description                    |
      | http://www.whitehouse.gov/news/hidden/1 | First hidden item | hiddenuuid1 | week          | First hidden news for the feed |
    And feed "Noticias" has the following news items:
      | link                              | title          | guid    | published_ago | published_at | description                             | subject        |
      | http://www.gobiernousa.gov/news/1 | Obama Noticia uno    | esuuid1 | day           |              | item First news item for the feed | economy        |
      | http://www.gobiernousa.gov/news/2 | Obama Noticia dos    | esuuid2 | day           |              | item Next news item for the feed  | jobs           |
      | http://www.gobiernousa.gov/news/3 | Obama Noticia tres   | esuuid3 | day           |              | item Next news item for the feed  | health         |
      | http://www.gobiernousa.gov/news/4 | Obama Noticia cuatro | esuuid4 | day           |              | item Next news item for the feed  | foreign policy |
      | http://www.gobiernousa.gov/news/5 | Obama Noticia cinco  | esuuid5 | day           | 2012-10-1    | item Next news item for the feed  | education      |
      | http://www.gobiernousa.gov/news/6 | Obama Noticia seis   | esuuid6 | day           | 2012-10-17   | item Next news item for the feed  | olympics       |
    And feed "es_agency_channel_id" has the following news items:
      | link                                       | title             | guid     | published_ago | description                        |
      | http://www.youtube.com/watch?v=EqExXXahb0s | Noticia video uno Obama | esvuuid1 | day           | video news item for the feed |
      | http://www.youtube.com/watch?v=C5WWyZ0cTcM | Noticia video dos Obama | esvuuid2 | day           | video news item for the feed |
    And the following SAYT Suggestions exist for bar.gov:
      | phrase           |
      | Some Unique item |
      | el paso term     |
    When I am on bar.gov's search page
    And I fill in "Enter your search term" with "first item"
    And I press "Search" in the legacy search box
    Then I should see "News for 'first item' by bar site"
    And I should not see "stale"
    And I should see "First <b> item </b>" in the rss feed govbox
    And I should not see "First video item" in the rss feed govbox
    And I should not see "Photo Gallery 7 days ago"
    And I should see "Videos of 'first item' by bar site"
    And I should see "First video item" in the video rss feed govbox
    And I should see an image with alt text "First video item"
    And I should see an image with src "https://i.ytimg.com/vi/0hLMc-6ocRk/default.jpg"
    And I should not see "First item" in the video rss feed govbox
    And I should not see "Show Options" in the left column
    And I should not see "Hide Options" in the left column

    When I follow "News for 'first item'"
    Then I should be on the news search page
    And I should have the following query string:
      |affiliate|bar.gov   |
      |query    |first item|
    And I should see "Show Options" in the left column
    And I should see "Hide Options" in the left column
    And I should see "First <b> item </b>"
    And I should see "i> item </i> First news item for the feed"
    And I should see "First video item"
    And I should see a link to "Advanced Search" in the advanced search section

    When I am on bar.gov's search page
    And I fill in "query" with "first item"
    And I press "Search" in the legacy search box
    And I follow "Videos of 'first item'"
    Then I should have the following query string:
      |affiliate|bar.gov   |
      |query    |first item|
    And I should see "Videos" in the left column
    And I should not see a link to "Videos"
    Then I should see "First video item"
    And I should not see "First item"
    When I follow "Last year" in the results filters
    And I fill in "query" with "second item"
    And I press "Search" in the legacy search box
    Then I should see "Videos" in the left column
    And I should not see a link to "Videos"
    And I should see "Second video item"
    And I should not see "Second item"

    When I am on bar.gov's search page
    And I fill in "query" with "loren"
    And I press "Search" in the legacy search box
    Then I should not see "News for 'loren' from bar site"

    When there are 30 video news items for "en_agency_channel_id"
    And I am on bar.gov's search page
    And I follow "Videos"
    Then I should see "32 results"
    And I should see 20 video news results

    When I am on es.bar.gov's search page
    And I fill in "Ingrese su búsqueda" with "noticia uno"
    And I press "Buscar" in the legacy search box
    Then I should see "Videos de 'noticia uno' de Spanish bar site"
    And I should see "Noticia video uno" in the video rss feed govbox

    When I am on bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search" in the legacy search box
    Then I should see "Everything"
    And I should see "Images"
    And I should see "Press"
    And I should see "Photo Gallery"
    And I should see "Videos"
    And I should not see "Hide Me" in the left column
    And I should not see "Any time"
    And I should not see "Last hour"
    And I should not see "Last day"
    And I should not see "Last week"
    And I should not see "Last month"
    And I should not see "Last year"

    When I follow "Videos"
    Then I should see the browser page titled "item - bar site Search Results"
    And I should see 20 video news results
    And I should see an image with src "https://i.ytimg.com/vi/R2RWscJM97U/default.jpg"
    And I should see yesterday's date in the English search results

    When I am on bar.gov's news search page
    And I fill in "query" with "item"
    And I press "Search" in the legacy search box
    And I follow "Photo Gallery"
    And I follow "Last hour"
    Then I should see "no results found for 'item'"

    When I follow "Everything" in the left column
    Then I should not see a link to "Everything" in the left column

    When I follow "Photo Gallery"
    Then I should see "no results found for 'item'"

    When I follow "Any time"
    Then I should see "item More news items for the feed"
    And I should see "item Last news item for the feed"

    When I follow "Everything"
    Then I should see "Advanced Search"
    And I should see "Search" button

    When I am on es.bar.gov's search page
    And I fill in "query" with "obama"
    And I press "Buscar" in the legacy search box
    Then I should see the browser page titled "obama - Spanish bar site resultados de la búsqueda"
    And I should see "Todo"
    And I should not see "Everything" in the left column
    And I should see "Imágenes"
    And I should see "Spanish Videos"
    And I should not see "Images" in the left column
    And I should not see "Search this site"
    And I should not see "Mostrar opciones" in the left column
    And I should not see "Ocultar opciones" in the left column
    And I should not see "Cualquier fecha"
    And I should not see "Any time"
    And I should see "Noticias sobre de 'obama' de Spanish bar site"
    And I should see "Videos de 'obama' de Spanish bar site"

    When I follow "Noticias sobre de 'obama'"
    Then I should see "Mostrar opciones" in the left column
    And I should see "Ocultar opciones" in the left column
    And I should see "Noticia uno"
    And I should see "Noticia video uno Obama"

    When I am on es.bar.gov's search page
    And I fill in "query" with "obama"
    And I press "Buscar" in the legacy search box
    And I follow "Videos de 'obama'"
    Then I should see "Noticia video uno Obama"
    And I should not see "Noticia uno"

    When I am on es.bar.gov's search page
    And I fill in "query" with "obama"
    And I press "Buscar" in the legacy search box
    And I follow "Spanish Videos"
    Then I should see "Cualquier fecha"
    Then I should see 2 video news results
    And I should see an image with alt text "Noticia video uno Obama"
    And I should see an image with src "https://i.ytimg.com/vi/EqExXXahb0s/default.jpg"
    And I should see yesterday's date in the Spanish search results

  Scenario: Searching news items using time filters
    Given the following legacy Affiliates exist:
      | display_name                 | name       | contact_email | contact_name | locale | youtube_handles |
      | bar site                     | bar.gov    | aff@bar.gov   | John Bar     | en     | en_agency       |
      | Spanish bar site             | es.bar.gov | aff@bar.gov   | John Bar     | es     | es_agency       |
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                                | is_navigable | is_managed |
      | Press         | http://www.whitehouse.gov/feed/press               | true         |            |
      | Photo Gallery | http://www.whitehouse.gov/feed/media/photo-gallery | true         |            |
      | Videos        |                                                    | true         | true       |
      | Hide Me       | http://www.whitehouse.gov/feed/media/hidden        | false        |            |
    And affiliate "es.bar.gov" has the following RSS feeds:
      | name                  | url                                                              | is_navigable | is_managed |
      | Noticias              | http://www.usa.gov/gobiernousa/rss/actualizaciones-articulos.xml | true         |            |
      | Spanish Photo Gallery | http://www.whitehouse.gov/feed/media/es-photo-gallery            | true         |            |
      | Spanish Videos        |                                                                  | true         | true       |
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
    And feed "en_agency_channel_id" has the following news items:
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
    And feed "es_agency_channel_id" has the following news items:
      | link                                       | title                     | guid     | published_ago | description                           |
      | http://www.youtube.com/watch?v=EqExXXahb0s | First Spanish video item  | esvuuid1 | day           | Gobierno video news item for the feed |
      | http://www.youtube.com/watch?v=C5WWyZ0cTcM | Second Spanish video item | esvuuid2 | day           | Gobierno video news item for the feed |
    And the following SAYT Suggestions exist for bar.gov:
      | phrase           |
      | Some Unique item |
      | el paso term     |
    When I am on bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search" in the legacy search box
    And I follow "Press"
    Then I should see "Any time" in the results filters
    And I should not see a link to "Any time" in the results filters
    And the "From:" field should be blank
    And the "To:" field should be blank
    And I should see "Most recent" in the selected sort filter
    And I should not see a link to "Most recent" in the results filters
    And I should see a link to "Best match" in the results filters
    When I follow "Last week"
    Then I should see a link to "Any time" in the results filters
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
    And I press "Search" in the legacy search box
    And the "From:" field should contain "9/30/2012"
    And the "To:" field should contain "10/15/2012"
    And I should see a link to "Third item" with url for "http://www.whitehouse.gov/news/3"
    And I should not see a link to "Fourth item"

    When I follow "Any time" in the results filters
    Then the "From:" field should be blank
    And the "To:" field should be blank

    When I am on bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search" in the legacy search box
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
    And I press "Search" in the legacy search box
    And I follow "Press"
    And I fill in "From:" with "9/30/2012"
    And I fill in "To:" with "10/15/2012"
    And I press "Search" in the results filters
    And I follow "Last year"
    Then I should see "Last year" in the selected time filter

    When I am on es.bar.gov's search page
    And I fill in "query" with "item"
    And I press "Buscar" in the legacy search box
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
    And I press "Buscar" in the legacy search box
    Then the "Desde:" field should contain "30/9/2012"
    And the "Hasta:" field should contain "15/10/2012"
    And I should see a link to "Fifth Spanish item" with url for "http://www.gobiernousa.gov/news/5"
    And I should not see a link to "Sixth Spanish item"

  Scenario: Searching news items with default dublin core mappings
    Given the following legacy Affiliates exist:
      | display_name     | name       | contact_email | contact_name | locale |
      | bar site         | en.bar.gov | aff@bar.gov   | John Bar     | en     |
      | Spanish bar site | es.bar.gov | aff@bar.gov   | John Bar     | es     |
    And affiliate "en.bar.gov" has the following RSS feeds:
      | name          | url                                                                  | is_navigable |
      | Press         | http://www.whitehouse.gov/feed/press                                 | true         |
      | Videos        | http://gdata.youtube.com/feeds/base/videos?alt=rss&author=whitehouse | true         |
    And affiliate "es.bar.gov" has the following RSS feeds:
      | name           | url                                                                    | is_navigable |
      | Noticias       | http://www.usa.gov/gobiernousa/rss/actualizaciones-articulos.xml       | true         |
      | Spanish Videos | http://gdata.youtube.com/feeds/base/videos?alt=rss&author=eswhitehouse | true         |
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
    And I press "Search" in the legacy search box
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
    And I press "Buscar" in the legacy search box
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

  Scenario: Searching a domain with Bing results that match a specific news item
    Given the following legacy Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains        |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | whitehouse.gov |
    And affiliate "bar.gov" has the following RSS feeds:
      | name  | url                                  | is_navigable |
      | Press | http://www.whitehouse.gov/feed/press | true         |
    And feed "Press" has the following news items:
      | link                                                                                                 | title              | guid  | published_ago | description         |
      | https://www.whitehouse.gov/blog/2014/03/11/watch-president-obama-between-two-ferns-zach-galifianakis | two ferns RSS test | uuid1 | day           | two ferns news item |
    When I am on bar.gov's search page
    And I fill in "query" with "two ferns"
    And I press "Search" in the legacy search box
    Then I should see "two ferns RSS test"

  Scenario: No results when searching with active RSS feeds
    Given the following legacy Affiliates exist:
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
    And I press "Search" in the legacy search box
    Then I should see at least 2 search results

    When I follow "Press"
    Then I should see "Sorry, no results found for 'item'. Remove all filters or try entering fewer or broader query terms."
    When I follow "Remove all filters"
    Then I should see at least 2 search results

    When I fill in "query" with "item"
    And I press "Search" in the legacy search box
    And I follow "Photo Gallery"
    Then I should see "item More news items for the feed"
    When I follow "Last day"
    Then I should see "Sorry, no results found for 'item' in the last day. Remove all filters or try entering fewer or broader query terms."
    When I follow "Remove all filters"
    Then I should see at least 2 search results

  Scenario: No results when searching on Spanish site with active RSS feeds
    Given the following legacy Affiliates exist:
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
    And I press "Buscar" in the legacy search box
    Then I should see at least 2 search results

    When I follow "Press"
    Then I should see "No hemos encontrado ningún resultado que contenga 'item'. Elimine los filtros de su búsqueda, use otras palabras clave o intente usando sinónimos."
    When I follow "Elimine los filtros"
    Then I should see at least 2 search results

    When I fill in "query" with "item"
    And I press "Buscar" in the legacy search box
    And I follow "Photo Gallery"
    And I follow "Último día"
    Then I should see "No hemos encontrado ningún resultado que contenga 'item' en el último día. Elimine los filtros de su búsqueda, use otras palabras clave o intente usando sinónimos."
    When I follow "Elimine los filtros"
    Then I should see at least 2 search results

  Scenario: Searching on a site with media RSS
    Given the following legacy Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     |
    And affiliate "bar.gov" has the following RSS feeds:
      | name   | url                                   | is_navigable | show_only_media_content |
      | Photos | http://www.whitehouse.gov/feed/photos | true         | true                    |
    And feed "Photos" has the following news items:
      | link                              | title   | description     | guid  | published_ago | thumbnail_url                          | content_url                            |
      | http://www.whitehouse.gov/photo/1 | Photo 1 | desc of photo 1 | uuid1 | week          | http://www.whitehouse.gov/media/t1.png | http://www.whitehouse.gov/media/c1.png |
      | http://www.whitehouse.gov/photo/2 | Photo 2 | desc of photo 2 | uuid2 | week          | http://www.whitehouse.gov/media/t2.png | http://www.whitehouse.gov/media/c2.jpg |
      | http://www.whitehouse.gov/photo/3 | Photo 3 | no media        | uuid3 | week          |                                        |                                        |
    When I am on bar.gov's "Photos" news search page
    And I fill in "query" with "photo"
    And I press "Search" in the legacy search box
    Then I should see 2 image news results

  Scenario: Visiting English affiliate search with multiple domains
    Given the following legacy Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains                |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | whitehouse.gov,usa.gov |
    When I am on bar.gov's search page
    And I fill in "Enter your search term" with "president"
    And I press "Search" in the legacy search box
    Then I should see at least 2 search results
    And I should not see "Search this site"

  Scenario: Visiting Spanish affiliate search with multiple domains
    Given the following legacy Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains                | locale | is_image_search_navigable |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | whitehouse.gov,usa.gov | es     | true                      |
    When I am on bar.gov's search page
    And I fill in "Ingrese su búsqueda" with "president"
    And I press "Buscar" in the legacy search box
    Then I should see at least 2 search results
    And I should see "Todo"
    And I should not see "Everything"
    And I should see "Imágenes"
    And I should not see "Images"
    And I should not see "Search this site"

  @javascript
  Scenario: Searchers see English Medline Govbox
    Given the following legacy Affiliates exist:
      | display_name | name        | contact_email | contact_name | domains | is_medline_govbox_enabled |
      | english site | english-nih | aff@bar.gov   | John Bar     | nih.gov | true                      |
    And the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 67890       | es     | Hippopotomonstrosesquippedaliophobia y otros miedos irracionales |
    When I am on english-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search" in the legacy search box
    Then I should not see "Hippopotomonstrosesquippedaliophobia y otros miedos irracionales"

    Given the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 12345       | en     | Hippopotomonstrosesquippedaliophobia and Other Irrational Fears  |
    And the following Related Medline Topics for "Hippopotomonstrosesquippedaliophobia" in English exist:
      | medline_title | medline_tid | url                                                                          |
      | Hippo1        | 24680       | https://www.nlm.nih.gov/medlineplus/Hippopotomonstrosesquippedaliophobia.html |
    When I am on english-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search" in the legacy search box
    Then I should see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears" in the medline govbox
    And I should see a link to "Hippo1" with url for "https://www.nlm.nih.gov/medlineplus/Hippopotomonstrosesquippedaliophobia.html"

    Given I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the english-nih's Manage Display page
    And I switch off "Is medline govbox enabled"
    And I press "Save"

    When I am on english-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Search" in the legacy search box
    Then I should not see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears"

  @javascript
  Scenario: Searchers see Spanish Medline Govbox
    Given the following legacy Affiliates exist:
      | display_name | name        | contact_email | contact_name | domains | is_medline_govbox_enabled | locale |
      | spanish site | spanish-nih | aff@bar.gov   | John Bar     | nih.gov | true                      | es     |
    And the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 12345       | en     | Hippopotomonstrosesquippedaliophobia and Other Irrational Fears  |
    When I am on spanish-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Buscar" in the legacy search box
    Then I should not see "Hippopotomonstrosesquippedaliophobia and Other Irrational Fears"

    Given the following Medline Topics exist:
      | medline_title                        | medline_tid | locale | summary_html                                                     |
      | Hippopotomonstrosesquippedaliophobia | 67890       | es     | Hippopotomonstrosesquippedaliophobia y otros miedos irracionales |
    When I am on spanish-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Buscar" in the legacy search box
    Then I should see "Hippopotomonstrosesquippedaliophobia y otros miedos irracionales" in the medline govbox

    Given I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the spanish-nih's Manage Display page
    And I switch off "Is medline govbox enabled"
    And I press "Save"

    When I am on spanish-nih's search page
    And I fill in "query" with "hippopotomonstrosesquippedaliophobia"
    And I press "Buscar" in the legacy search box
    Then I should not see "Hippopotomonstrosesquippedaliophobia y otros miedos irracionales"

  Scenario: When a searcher enters a query with invalid Lucene character
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     | .gov    |
    And I am on agency.gov's search page
    And I fill in "query" with "++health it"
    And I press "Search" in the legacy search box
    Then I should see the browser page titled "++health it - agency site Search Results"
    And I should see some Bing search results
    When I fill in "query" with "OR US97 central"
    And I press "Search" in the legacy search box
    Then I should see the browser page titled "OR US97 central - agency site Search Results"
    And I should see some Bing search results

  Scenario: When a searcher clicks on a collection on sidebar and the query is blank
    Given the following legacy Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And affiliate "aff.gov" has the following document collections:
      | name   | prefixes               | is_navigable |
      | Topics | http://aff.gov/topics/ | true         |
    When I go to aff.gov's search page
    And I follow "Topics" in the left column
    Then I should see "Please enter a search term"

  Scenario: When a searcher on an English site clicks on an RSS Feed on sidebar and the query is blank
    Given the following legacy Affiliates exist:
      | display_name     | name       | contact_email | contact_name | locale | youtube_handles |
      | bar site         | bar.gov    | aff@bar.gov   | John Bar     | en     | en_agency       |
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
    And I press "Search" in the legacy search box
    And I follow "Videos of 'first item'"
    And I fill in "query" with ""
    And I press "Search" in the legacy search box
    Then I should see the browser page titled "Videos - bar site Search Results"

  Scenario: When a searcher on a Spanish site clicks on an RSS Feed on sidebar and the query is blank
    Given the following legacy Affiliates exist:
      | display_name     | name       | contact_email | contact_name | locale | youtube_handles |
      | Spanish bar site | es.bar.gov | aff@bar.gov   | John Bar     | es     | es_agency       |
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
    And I press "Buscar" in the legacy search box
    And I follow "Videos de 'noticia uno'"
    And I fill in "query" with ""
    And I press "Buscar" in the legacy search box
    Then I should see the browser page titled "Spanish Videos - Spanish bar site resultados de la búsqueda"

  Scenario: When there are relevant Tweets from Twitter profiles associated with the affiliate
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email | contact_name | locale |
      | bar site     | bar.gov    | aff@bar.gov   | John Bar     | en     |
      | spanish site | es.bar.gov | aff@bar.gov   | John Bar     | es     |
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
    And I fill in "query" with "season"
    And I press "Search" in the legacy search box
    Then I should see "Recent tweet for 'season' by bar site"
    And I should see a link to "USAgov" with url for "http://twitter.com/USAgov"
    And I should see "USA.gov @USAgov"
    And I should see a link to "http://t.co/YQQSs9bb" with text "tmblr.co/Z8xAVxUEK..."
    And I should see "season" in bold font
    And I should not see "Summer season is great!"

    When I am on es.bar.gov's search page
    And I fill in "query" with "Estados Unidos amiga"
    And I press "Buscar" in the legacy search box
    Then I should see "Tweet más reciente para 'Estados Unidos amiga' de spanish site"
    And I should see a link to "GobiernoUSA.gov" with url for "http://twitter.com/GobiernoUSA"
    And I should see "GobiernoUSA.gov @GobiernoUSA"
    And I should see "Estados Unidos por amigos!"
    And I should see "Estados" in bold font in the twitter govbox
    And I should see "Unidos" in bold font in the twitter govbox
    And I should see "amigos" in bold font in the twitter govbox

  Scenario: Searching document collections
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains        |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     | whitehouse.gov |
    And affiliate "agency.gov" has the following document collections:
      | name      | prefixes                 | is_navigable |
      | Petitions | petitions.whitehouse.gov | true         |
    And the following IndexedDocuments exist:
      | title                   | description                                         | url                                             | affiliate  | last_crawled_at | last_crawl_status |
      | First petition article  | This is an article death star r2d2 xyz3 petition    | http://petitions.whitehouse.gov/petition-1.html | agency.gov | 11/02/2011      | OK                |
      | Second petition article | This is an article on death r2d2 xyz3 star petition | http://petitions.whitehouse.gov/petition-2.html | agency.gov | 11/02/2011      | OK                |
    When I am on agency.gov's search page
    And I follow "Petitions" in the left column
    And I fill in "Enter your search term" with "'death star r2d2 xyz3'"
    And I press "Search" in the legacy search box
    Then I should see a link to "First petition article" with url for "http://petitions.whitehouse.gov/petition-1.html"
    And I should see a link to "Second petition article" with url for "http://petitions.whitehouse.gov/petition-2.html"

  Scenario: Searching on non navigable document collection
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     | usa.gov |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes            | is_navigable |
      | Blog | http://www.sba.gov/blogs | false        |
      | Web  | https://www.usa.gov  | true         |
    When I am on agency.gov's "Blog" docs search page
    Then I should see "Blog" in the left column
    And I should not see a link to "Everything" in the left column
    And I should not see a link to "Blog" in the left column
    And I should not see a link to "Search Notes" in the left column
    When I fill in "query" with "Noaa"
    And I press "Search" in the legacy search box
    Then I should see some Bing search results
    And I should not see a link to "Everything" in the left column
    And I should not see a link to "Blog" in the left column
    And I should not see a link to "Search Notes" in the left column

  Scenario: Searching with malformed query
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email | contact_name | is_image_search_navigable |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     | true                      |
    When I am on agency.gov's search page with unsanitized "hello" query
    Then I should see a link to "Images" with sanitized "hello" query

  Scenario: Searching for site specific results using query
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     | usa.gov |
    When I am on agency.gov's search page
    And I fill in "query" with "jobs site:www.usa.gov"
    And I press "Search" in the legacy search box
    Then I should see "www.usa.gov/"
    And I fill in "query" with "jazz site:wikipedia.org"
    And I press "Search" in the legacy search box
    Then I should not see "en.wikipedia.org/wiki/Jazz"

  Scenario: Searching for site specific results using sitelimit
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains | is_image_search_navigable |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     | .gov    | true                      |
    And affiliate "agency.gov" has the following document collections:
      | name | prefixes                         | is_navigable |
      | Blog | http://usasearch.howto.gov/blog/ | true         |
    And affiliate "agency.gov" has the following RSS feeds:
      | name  | url                                                | is_navigable |
      | Press | http://www.whitehouse.gov/feed/press               | true         |
      | Photo | http://www.whitehouse.gov/feed/media/photo-gallery | true         |
    When I am on agency.gov's search page with site limited to "www.usa.gov"
    And I fill in "query" with "jobs"
    And I press "Search" in the legacy search box
    Then I should see "www.usa.gov/"

    When I follow "Images" in the left column
    And I press "Search" in the legacy search box
    And I follow "Everything" in the left column
    Then I should see "www.usa.gov/"

    When I follow "Blog" in the left column
    And I press "Search" in the legacy search box
    And I follow "Everything" in the left column
    Then I should see "www.usa.gov/"

    When I follow "Press" in the left column
    And I press "Search" in the legacy search box
    And I follow "Everything" in the left column
    Then I should see "www.usa.gov/"

    When I follow "Press" in the left column
    And I fill in "From:" with "1/30/2012"
    And I press "Search" in the results filters
    And I follow "Any time" in the results filters
    And I follow "Everything" in the left column
    Then I should see "www.usa.gov/"

  Scenario: Visiting affiliate with strictui parameters
    Given the following legacy Affiliates exist:
      | display_name | name    | contact_email | contact_name | external_css_url                | header                                                                  | footer                                                                  |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     | http://cdn.aff.gov/external.css | <style>#my_header { color:red } </style> <h1 id='my_header'>header</h1> | <style>#my_footer { color:red } </style> <h1 id='my_footer'>footer</h1> |
    When I go to aff.gov's strictui search page
    Then I should not see the page with external affiliate stylesheet "http://cdn.aff.gov/external.css"
    And I should not see tainted SERP header
    And I should not see tainted SERP footer

  Scenario: Affiliate search on affiliate with connections
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email | contact_name | domains |
      | agency site  | agency.gov | aff@bar.gov   | John Bar     | .gov    |
      | other site   | other.gov  | aff@bad.gov   | John Bad     | .gov    |
    And the following Connections exist for the affiliate "agency.gov":
    | connected_affiliate   |   display_name    |
    | other.gov             |  Other Site       |
    When I am on agency.gov's search page
    And I fill in "query" with "jobs"
    And I press "Search" in the legacy search box
    Then I should see "Other Site"
    When I follow "Other Site"
    Then I should see the browser page titled "jobs - other site Search Results"

  Scenario: Searching on sites with Featured Collections
    Given the following legacy Affiliates exist:
      | display_name   | name          | contact_email   | contact_name | locale |
      | agency site    | agency.gov    | john@agency.gov | John Bar     | en     |
    And the following featured collections exist for the affiliate "agency.gov":
      | title           | title_url                         | status   | publish_start_on | publish_end_on |
      | Tornado Warning | http://agency.gov/tornado-warning | active   | 2013-07-01       |                |
    And the following featured collection links exist for featured collection titled "Tornado Warning":
      | title                 | url                                          |
      | Atlantic              | http://www.nhc.noaa.gov/aboutnames.shtml#atl |
      | Eastern North Pacific | http://www.nhc.noaa.gov/aboutnames.shtml#enp |
    When I am on agency.gov's search page
    And I fill in "query" with "warnings for a tornado"
    And I press "Search" in the legacy search box
    Then I should see "Tornado Warning by agency site" in the featured collections section
    And I should see a link to "Atlantic" with url for "http://www.nhc.noaa.gov/aboutnames.shtml#atl" on the left featured collection link list
    And I should see a link to "Eastern North Pacific" with url for "http://www.nhc.noaa.gov/aboutnames.shtml#enp" on the right featured collection link list
    When I fill in "query" with "Atlantic"
    And I press "Search" in the legacy search box
    Then I should see a featured collection link title with "Atlantic" highlighted

  Scenario: Searching on sites with Boosted Contents
    Given the following legacy Affiliates exist:
      | display_name   | name          | contact_email   | contact_name | locale |
      | agency site    | agency.gov    | john@agency.gov | John Bar     | en     |
      | es agency site | es.agency.gov | john@agency.gov | John Bar     | es     |
    And the following Boosted Content entries exist for the affiliate "agency.gov"
      | url                                                 | title                               | description        | status   | publish_start_on | publish_end_on |
      | http://usasearch.howto.gov/releases/2013-05-31.html | Notes for Week Ending May 31, 2013  | multimedia gallery | active   | 2013-08-01       | 2022-01-01     |
      | http://usasearch.howto.gov/releases/2013-06-21.html | Notes for Week Ending June 21, 2013 | spring cleaning    | inactive |                  |                |
    And the following Boosted Content entries exist for the affiliate "es.agency.gov"
      | title                             | url                       | description |
      | la página de prueba de Emergencia | http://www.agency.gov/911 | Some terms  |
    When I am on agency.gov's search page
    And I fill in "query" with "notes"
    And I press "Search" in the legacy search box
    Then I should see a link to "Notes for Week Ending May 31, 2013" with url for "http://usasearch.howto.gov/releases/2013-05-31.html" in the boosted contents section
    And I should not see a link to "Notes for Week Ending June 21, 2013"

    When I am on es.agency.gov's search page
    And I fill in "query" with "emergencia"
    And I press "Buscar" in the legacy search box
    Then I should see a link to "la página de prueba de Emergencia" with url for "http://www.agency.gov/911" in the boosted contents section

  Scenario: Searching news items with custom dublin core mappings
    Given the following legacy Affiliates exist:
      | display_name | name       | contact_email | contact_name | locale | dc_contributor          | dc_publisher          | dc_subject |
      | bar site     | en.bar.gov | aff@bar.gov   | John Bar     | en     | Administration Official | Briefing Room Section | Issue      |
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

  Scenario: Entering a blank advanced search
    Given the following legacy Affiliates exist:
      | display_name | name   | contact_email | contact_name | header         |
      | USA.gov      | usagov | aff@bar.gov   | John Bar     | USA.gov Header |
    When I am on usagov's advanced search page
    And I press "Search"
    Then I should be on the search page
    And I should see "Please enter a search term"

  Scenario: When using tablet device on advanced search
    Given I am using an tabletPC device
    And the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     |
    When I am on bar.gov's advanced search page
    And I press "Search"
    Then I should be on the search page
    And I should see "Please enter a search term"

  Scenario: Web search using Azure engine
    Given the following legacy Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale | search_engine | domains |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     | Azure | .gov    |
    And affiliate "en.agency.gov" has the following document collections:
      | name    | prefixes            |
      | USA.gov | https://www.usa.gov |
    When I am on en.agency.gov's search page
    And I fill in "query" with "agency"
    And I press "Search"
    Then I should not see legacy results count
    And I should see 20 search results
    And I should see the Results by Azure logo
