Feature: Searches using mobile device

  Background:
    Given I am using a TabletPC device

  Scenario: Web search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale | domains              |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     |                      |
      | Spanish site | es.agency.gov | admin@agency.gov | John Bar     | es     |                      |
      | Hippo site   | hippo         | admin@agency.gov | John Bar     | en     | hippo.whitehouse.gov |
    And the following Boosted Content entries exist for the affiliate "en.agency.gov"
      | url                                                             | title                  | description                             |
      | http://http://www.whitehouse.gov/administration/president-obama | President Barack Obama | the 44th President of the United States |
      | http://www.whitehouse.gov/about/presidents/georgewbush          | George W. Bush         | the 43rd President of the United States |
      | http://www.whitehouse.gov/about/presidents/williamjclinton      | William J. Clinton     | the 42nd President of the United States |
    And the following Boosted Content entries exist for the affiliate "es.agency.gov"
      | url                                                             | title                         | description                             |
      | http://http://www.whitehouse.gov/administration/president-obama | Presidente Barack Obama       | the 44th President of the United States |
      | http://www.whitehouse.gov/about/presidents/georgewbush          | Presidente George W. Bush     | the 43rd President of the United States |
      | http://www.whitehouse.gov/about/presidents/williamjclinton      | Presidente William J. Clinton | the 42nd President of the United States |
    And the following Boosted Content entries exist for the affiliate "hippo"
      | url                                     | title                  | description                                            |
      | http://hippo.gov/hippopotamus-amphibius | Hippopotamus amphibius | large, mostly herbivorous mammal in sub-Saharan Africa |
    And the following featured collections exist for the affiliate "en.agency.gov":
      | title                       | title_url                                  | status | publish_start_on | publish_end_on | image_file_path            |
      | The 21st Century Presidents | http://www.whitehouse.gov/about/presidents | active | 2013-07-01       |                | features/support/small.jpg |
    And the following featured collection links exist for featured collection titled "The 21st Century Presidents":
      | title                           | url                                                                    |
      | 44. Barack Obama                | http://www.whitehouse.gov/about/presidents/barackobama                 |
      | 43. George W. Bush              | http://www.whitehouse.gov/about/presidents/georgewbush                 |
      | The Presidents Photo Galleries  | http://www.whitehouse.gov/photos-and-video/photogallery/the-presidents |
    And the following featured collections exist for the affiliate "es.agency.gov":
      | title          | status | publish_start_on |
      | Lo Más Popular | active | 2013-07-01       |
    And the following featured collection links exist for featured collection titled "Lo Más Popular":
      | title                                               | url                                                                           |
      | Presidente Barack Obama: ganador elecciones de 2012 | http://www.usa.gov/gobiernousa/Temas/Votaciones/Presidente-Barack-Obama.shtml |
      | Servicios por Internet                              | http://www.usa.gov/gobiernousa/Temas/Servicios.shtml                          |
      | Seguros de salud                                    | http://www.usa.gov/gobiernousa/Salud-Nutricion-Seguridad/Salud/Seguros.shtml  |
    And the following Twitter Profiles exist:
      | screen_name | name          | twitter_id | affiliate     |
      | USASearch   | USASearch.gov | 123456     | en.agency.gov |
    And the following Tweets exist:
      | tweet_text                                                                                    | tweet_id | published_ago | twitter_profile_id | url                    | expanded_url            | display_url      |
      | President Obama: "Don’t Just Play on Your Phone, Program It"                                  | 234567   | week          | 123456             |                        |                         |                  |
      | "We wish you all a blessed and safe holiday season." - President Obama http://t.co/l8jbZSbmAX | 184957   | hour          | 123456             | http://t.co/l8jbZSbmAX | http://go.wh.gov/sgCp3q | go.wh.gov/sgCp3q |
    And the following SAYT Suggestions exist for en.agency.gov:
      | phrase                 |
      | president list         |
      | president inauguration |
    When I am on en.agency.gov's mobile search page
    And I fill in "Enter your search term" with "president"
    And I press "Search"
    Then I should see Powered by Bing logo
    And I should see 3 Best Bets Texts
    And I should see 1 Best Bets Graphic
    And I should see "44. Barack Obama 43. George W. Bush The Presidents Photo Galleries"
    And I should see "Show more"
    And I should see "Show less"
    And I should see a link to "http://t.co/l8jbZSbmAX" with text "go.wh.gov/sgCp3q"
    And I should see at least "2" web search results
    And I should see 2 related searches

    When I am on es.agency.gov's mobile search page
    And I fill in "Ingrese su búsqueda" with "presidente"
    And I press "Buscar"
    Then I should see Generado por Bing logo
    And I should see 3 Best Bets Texts
    And I should see 1 Best Bets Graphic
    And I should see "Mostrar más"
    And I should see "Mostrar menos"
    And I should see at least "2" web search results

    When I am on hippo's mobile search page
    And I fill in "Enter your search term" with "hippopotamus"
    And I press "Search"
    Then I should see "Sorry, no results found for 'hippopotamus'."
    And I should see "Hippopotamus amphibius"

  Scenario: News search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     |
      | Spanish site | es.agency.gov | admin@agency.gov | John Bar     | es     |

    And affiliate "en.agency.gov" has the following RSS feeds:
      | name   | url                              |
      | News-1 | http://en.agency.gov/feed/news-1 |
    And affiliate "es.agency.gov" has the following RSS feeds:
      | name       | url                                  |
      | Noticias-1 | http://es.agency.gov/feed/noticias-1 |

    And there are 10 news items for "News-1"
    And there are 5 news items for "Noticias-1"

    When I am on en.agency.gov's "News-1" mobile news search page
    Then I should see "Powered by DIGITALGOV Search"
    And I should see at least "10" web search results

    When I am on es.agency.gov's "Noticias-1" mobile news search page
    Then I should see "Generado por DIGITALGOV Search"
    And I should see at least "5" web search results

  Scenario: Media RSS search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name |
      | English site | en.agency.gov | admin@agency.gov | John Bar     |
    And affiliate "en.agency.gov" has the following RSS feeds:
      | name   | url                              | is_navigable | show_only_media_content |
      | Images | http://en.agency.gov/feed/images | true         | true                    |
    And there are 10 image news items for "Images"
    When I am on en.agency.gov's search page
    When I follow "Images" within the SERP navigation
    And I fill in "Enter your search term" with "image"
    And I press "Search"
    Then I should see exactly "10" image search results
    And I should see "Powered by DIGITALGOV Search"

  Scenario: Video news search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale | youtube_handles         |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     | usgovernment,whitehouse |
      | Spanish site | es.agency.gov | admin@agency.gov | John Bar     | es     | gobiernousa             |
    And affiliate "en.agency.gov" has the following RSS feeds:
      | name   | url | is_navigable | is_managed |
      | Videos |     | true         | true       |
    And affiliate "es.agency.gov" has the following RSS feeds:
      | name   | url | is_navigable | is_managed |
      | Videos |     | true         | true       |
    And there are 10 video news items for "usgovernment"
    And there are 10 video news items for "whitehouse"
    And there are 5 video news items for "gobiernousa"

    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "video"
    And I press "Search"
    And I should see exactly "1" video govbox search result
    And I should see "More videos about video"
    And I follow "Videos" within the SERP navigation
    And I should see 1 search result title link with url for "http://www.youtube.com/watch?v=0"
    Then I should see "Powered by DIGITALGOV Search"
    And I should see at least "10" video search results

    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "video 5"
    And I press "Search"
    And I should see at least "1" video govbox search result
    And I should not see "More videos about video 5"

    When I am on es.agency.gov's search page
    And I fill in "Ingrese su búsqueda" with "video"
    And I press "Buscar"
    And I should see exactly "1" video govbox search results
    And I should see "Más videos sobre de video"
    When I follow "Videos" within the SERP navigation
    Then I should see "Generado por DIGITALGOV Search"
    And I should see at least "5" video search results

  Scenario: Site search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     |
      | Spanish site | es.agency.gov | admin@agency.gov | John Bar     | es     |

    And affiliate "en.agency.gov" has the following document collections:
      | name    | prefixes           |
      | USA.gov | http://www.usa.gov |

    And affiliate "es.agency.gov" has the following document collections:
      | name            | prefixes                       |
      | GobiernoUSA.gov | http://www.usa.gov/gobiernousa |

    When I am on en.agency.gov's "USA.gov" mobile site search page
    And I fill in "Enter your search term" with "gov"
    And I press "Search"
    Then I should see Powered by Bing logo
    And I should see at least "10" web search results

    When I am on es.agency.gov's "GobiernoUSA.gov" mobile site search page
    And I fill in "Ingrese su búsqueda" with "gobierno"
    And I press "Buscar"
    Then I should see Generado por Bing logo
    And I should see at least "10" web search results

  Scenario: Site navigations without dropdown menu
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     |
    And affiliate "en.agency.gov" has the following document collections:
      | name | prefixes                |
      | FAQs | http://answers.usa.gov/ |
    And affiliate "en.agency.gov" has the following RSS feeds:
      | name     | url                                | is_navigable |
      | Articles | http://en.agency.gov/feed/articles | true         |
    And there are 10 news items for "Articles"
    When I am on en.agency.gov's mobile search page
    Then I should see "Everything" within the SERP active navigation

    When I fill in "Enter your search term" with "news"
    And I press "Search"
    Then I should see "Everything" within the SERP active navigation
    And I should see at least "10" web search results

    When I follow "FAQs" within the SERP navigation
    And I press "Search"
    Then I should see "FAQs" within the SERP active navigation
    And I should see at least "10" web search results

    When I follow "Articles" within the SERP navigation
    Then I should see "Articles" within the SERP active navigation
    And I should see at least "10" web search results

  Scenario: Site navigations with dropdown menu
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     |
    And affiliate "en.agency.gov" has the following document collections:
      | name                 | prefixes                | position | is_navigable |
      | FAQs                 | http://answers.usa.gov/ | 0        | true         |
      | Apps                 | http://apps.usa.gov/    | 2        | true         |
      | Inactive site search | http://apps.usa.gov/    | 6        | false        |
    And affiliate "en.agency.gov" has the following RSS feeds:
      | name                 | url                                | is_navigable | position | show_only_media_content |
      | Articles             | http://en.agency.gov/feed/articles | true         | 1        | false                   |
      | Blog                 | http://en.agency.gov/feed/blog     | true         | 3        | false                   |
      | Media RSS            | http://en.agency.gov/feed/images   | true         | 4        | true                    |
      | Inactive news search | http://en.agency.gov/feed/news1    | false        | 5        | false                   |
      | News                 | http://en.agency.gov/feed/news2    | true         | 7        | false                   |
    And there are 10 news items for "News"

    When I am on en.agency.gov's mobile search page
    Then I should see "Everything" within the SERP active navigation
    And I fill in "Enter your search term" with "news"
    And I press "Search"

    Then I should see "Everything" within the SERP active navigation
    And I should see "Everything FAQs Articles More Apps Blog Media RSS News" within the SERP navigation
    And I should see at least "10" web search results

    When I follow "Apps" within the SERP navigation
    Then I should see "Apps" within the SERP active navigation
    And I should see "Everything FAQs Apps More Articles Blog Media RSS News" within the SERP navigation
    And I should see at least "10" web search results

    When I follow "News" within the SERP navigation
    Then I should see "News" within the SERP active navigation
    And I should see "Everything FAQs News More Articles Apps Blog Media RSS" within the SERP navigation
    And I should see at least "10" web search results

    When I follow "Media RSS" within the SERP navigation
    Then I should see "Media RSS" within the SERP active navigation
    And I should see "Everything FAQs Media RSS More Articles Apps Blog News" within the SERP navigation

    When I am on en.agency.gov's "Inactive site search" mobile site search page
    Then I should see "Inactive site search" within the SERP active navigation

    When I am on en.agency.gov's "Inactive news search" mobile news search page
    Then I should see "Inactive news search" within the SERP active navigation

  Scenario: Job search
    Given the following Affiliates exist:
      | display_name | name   | contact_email    | contact_name | jobs_enabled |
      | English site | usagov | admin@agency.gov | John Bar     | 1            |
    When I am on usagov's mobile search page
    And I fill in "Enter your search term" with "jobs"
    And I press "Search"
    Then I should see "Federal Job Openings"
    And I should see a link to "See all federal job openings" with url for "https://www.usajobs.gov/JobSearch/Search/GetResults?PostingChannelID=USASearch"

  Scenario: When using tablet device
    Given I am using a TabletPC device
    And the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     |
    When I am on bar.gov's search page
    And I fill in "Enter your search term" with "bar"
    And I press "Search"
    And I should see at least "2" web search results

  Scenario: Searching with matching med topic query
    Given the following Medline Topics exist:
      | medline_tid | medline_title     | medline_url                                              | locale | summary_html                                                                                                                                                                                                                                                                                                         |
      | 1558        | Alcohol           | http://www.nlm.nih.gov/medlineplus/alcohol.html          | en     | <p>If you are like many Americans, you drink alcohol at least occasionally. For many people, moderate drinking is probably safe.  It may even have health benefits, including reducing your risk of certain heart problems.</p>                                                                                      |
      | 1313        | Underage Drinking | http://www.nlm.nih.gov/medlineplus/underagedrinking.html | en     | <p>It is possible to drink legally and safely - when you're over 21. But if you're under 21, or if you drink too much at any age, alcohol can be especially risky. </p>                                                                                                                                              |
      | 1732        | Alcohol           | http://www.nlm.nih.gov/medlineplus/spanish/alcohol.html  | es     | <p>Si usted es como muchos estadounidenses, quizás consuma bebidas alcohólicas por lo menos ocasionalmente. Para muchas personas, beber moderadamente probablemente sea sano. Quizá hasta puede tener beneficios para la salud, entre los que se incluye disminuir el riesgo de padecer algunos problemas cardiacos. |
    And the following Related Medline Topics for "Alcohol" in English exist:
      | medline_title     | medline_tid | url                                                      |
      | Underage drinking | 1313        | http://www.nlm.nih.gov/medlineplus/underagedrinking.html |
    And the following Related Medline Topics for "Alcohol" in Spanish exist:
      | medline_title | medline_tid | url                                                        |
      | Alcoholismo   | 1733        | http://www.nlm.nih.gov/medlineplus/spanish/alcoholism.html |
    And the following Medline Sites exist:
      | medline_title | locale | title      | url                                                              |
      | Alcohol       | en     | Alcoholism | http://clinicaltrials.gov/search/open/condition=%22Alcoholism%22 |
    And the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale | is_medline_govbox_enabled |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     | true                      |
      | Spanish site | es.agency.gov | admin@agency.gov | John Bar     | es     | true                      |
    When I am on en.agency.gov's mobile search page
    And I fill in "Enter your search term" with "alcohol"
    And I press "Search"
    Then I should see a link to "Alcohol" with url for "http://www.nlm.nih.gov/medlineplus/alcohol.html" within the med topic govbox
    And I should see a link to "Underage drinking" with url for "http://www.nlm.nih.gov/medlineplus/underagedrinking.html" within the med topic govbox
    And I should see a link to "Alcoholism" with url for "http://clinicaltrials.gov/search/open/condition=%22Alcoholism%22" within the med topic govbox

    When I am on es.agency.gov's mobile search page
    And I fill in "Ingrese su búsqueda" with "alcohol"
    And I press "Buscar"
    Then I should see a link to "Alcohol" with url for "http://www.nlm.nih.gov/medlineplus/spanish/alcohol.html" within the med topic govbox
    And I should see a link to "Alcoholismo" with url for "http://www.nlm.nih.gov/medlineplus/spanish/alcoholism.html" within the med topic govbox

  Scenario: Searching with sitelimit
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale | domains |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     | .gov    |
      | Spanish site | es.agency.gov | admin@agency.gov | John Bar     | es     | .gov    |
    When I am on en.agency.gov's search page with site limited to "usa.gov"
    And I fill in "Enter your search term" with "gov"
    And I press "Search"
    Then I should see "We're including results for gov from usa.gov only."
    And I should see "Do you want to see results for gov from all sites?"
    When I follow "gov from all sites" within the search all sites row
    Then I should not see "We're including results for gov from usa.gov only."

    When I am on es.agency.gov's search page with site limited to "usa.gov"
    And I fill in "Ingrese su búsqueda" with "gobierno"
    And I press "Buscar"
    Then I should see "Los resultados para gobierno son solo de usa.gov."
    And I should see "¿Quiere ver resultados para gobierno de todos los sitios?"
    When I follow "gobierno de todos los sitios" within the search all sites row
    Then I should not see "Los resultados para gobierno son solo de usa.gov."

  Scenario: Searching with matching results on news govbox
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     |
      | Spanish site | es.agency.gov | admin@agency.gov | John Bar     | es     |
    And affiliate "en.agency.gov" has the following RSS feeds:
      | name   | url                              | is_navigable |
      | Press  | http://en.agency.gov/feed/press  | true         |
      | Photos | http://en.agency.gov/feed/photos | true         |
    And the rss govbox is enabled for the site "en.agency.gov"
    And affiliate "es.agency.gov" has the following RSS feeds:
      | name     | url                                | is_navigable |
      | Noticias | http://es.agency.gov/feed/noticias | true         |
    And the rss govbox is enabled for the site "es.agency.gov"
    And feed "Press" has the following news items:
      | link                         | title                     | guid       | published_ago | multiplier | description                      |
      | http://en.agency.gov/press/1 | First press <b> item </b> | pressuuid1 | day           | 1          | First news item for the feed     |
      | http://en.agency.gov/press/2 | Second item               | pressuuid2 | day           | 1          | item Next news item for the feed |
    And feed "Photos" has the following news items:
      | link                          | title                               | guid       | published_ago | multiplier | description                      |
      | http://en.agency.gov/photos/1 | First photo <b> item </b>           | photouuid1 | day           | 1          | First news item for the feed     |
      | http://en.agency.gov/photos/2 | Second item                         | photouuid2 | day           | 1          | item Next news item for the feed |
      | http://en.agency.gov/press/1  | First duplicate press <b> item </b> | pressuuid1 | day           | 7          | First news item for the feed     |
    And feed "Noticias" has the following news items:
      | link                            | title                     | guid         | published_ago | multiplier | description                      |
      | http://es.agency.gov/noticias/1 | Noticia uno <b> item </b> | noticiauuid1 | day           | 1          | First news item for the feed     |
      | http://es.agency.gov/noticias/2 | Second item               | noticiauuid2 | day           | 1          | item Next news item for the feed |
    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "first item"
    And I press "Search"
    Then I should see "First press <b> item </b>"
    And I should see "Press 1 day ago"
    And I should not see "First duplicate"

    When I am on es.agency.gov's search page
    And I fill in "Ingrese su búsqueda" with "noticia uno"
    And I press "Buscar"
    Then I should see "Noticia uno <b> item </b>"
    And I should see "Noticias Ayer"

  Scenario: Searching on sites with related sites
    Given the following Affiliates exist:
      | display_name | name           | contact_email    | contact_name | locale |
      | English site | en.agency.gov  | admin@agency.gov | John Bar     | en     |
      | All sites    | all.agency.gov | admin@agency.gov | John Bar     | en     |
      | Spanish site | es.agency.gov  | admin@agency.gov | John Bar     | es     |
    And the following Connections exist for the affiliate "en.agency.gov":
      | connected_affiliate | display_name         |
      | es.agency.gov       | Este tema en español |
      | all.agency.gov      | All sites            |
    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "gobierno"
    And I press "Search"
    And I should see a link to "Este tema en español"
    And I should see a link to "All sites"
    When I follow "Este tema en español" within the SERP navigation
    Then I should see the browser page titled "gobierno - Spanish site resultados de la búsqueda"
