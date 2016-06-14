@vcr
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
      | Gallery Link Number 1           | http://www.whitehouse.gov/photos-and-video/photogallery/1              |
      | Gallery Link Number 2           | http://www.whitehouse.gov/photos-and-video/photogallery/2              |
      | Gallery Link Number 3           | http://www.whitehouse.gov/photos-and-video/photogallery/3              |
      | Gallery Link Number 4           | http://www.whitehouse.gov/photos-and-video/photogallery/4              |
      | Gallery Link Number 5           | http://www.whitehouse.gov/photos-and-video/photogallery/5              |
      | Gallery Link Number 6           | http://www.whitehouse.gov/photos-and-video/photogallery/6              |
      | Gallery Link Number 7           | http://www.whitehouse.gov/photos-and-video/photogallery/7              |
      | Gallery Link Number 8           | http://www.whitehouse.gov/photos-and-video/photogallery/8              |
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
    And I should see 1 Best Bets Texts
    And I should see 1 Best Bets Graphic
    And I should see "44. Barack Obama 43. George W. Bush The Presidents Photo Galleries"
    And I should see a link to "http://t.co/l8jbZSbmAX" with text "go.wh.gov/sgCp3q"
    And I should see at least "2" web search results
    And I should see 2 related searches
    And I should see a link to "Next"
    And I should not see a link to "2" with class "pagination-numbered-link"
    When I follow "Next"
    Then I should see a link to "Previous"
    And I should see a link to "Next"
    And I should not see a link to "1" with class "pagination-numbered-link"
    And I should not see a link to "3" with class "pagination-numbered-link"
    When I follow "Previous"
    Then I should see a link to "Next"

    When I am on es.agency.gov's mobile search page
    And I fill in "Ingrese su búsqueda" with "presidente"
    And I press "Buscar"
    Then I should see Generado por Bing logo
    And I should see 1 Best Bets Texts
    And I should see 1 Best Bets Graphic
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

    And there are 150 news items for "News-1"
    And there are 5 news items for "Noticias-1"

    When I am on en.agency.gov's "News-1" mobile news search page
    And I fill in "Enter your search term" with "news item"
    And I press "Search" within the search box

    Then the "Enter your search term" field should contain "news item"
    And I should see "Any time" within the current time filter
    And I should see "Most recent" within the current sort by filter
    And I should see "150 RESULTS"
    And I should see "Powered by DIGITALGOV Search"
    And I should see exactly "20" web search results
    And I should see "Previous"
    And I should see a link to "2" with class "pagination-numbered-link"
    And I should see a link to "Next"
    When I follow "Next"
    Then I should see "150 RESULTS"
    And I should see exactly "20" web search results
    And I should see a link to "Previous"
    And I should see a link to "1" with class "pagination-numbered-link"
    And I should see "Next"
    When I follow "5"
    And I follow "7"
    And I follow "8"
    Then I should see "150 RESULTS"
    And I should see exactly "10" web search results

    When I follow "Last month"
    Then the "Enter your search term" field should contain "news item"
    And I should see "Last month" within the current time filter
    And I should see "Most recent" within the current sort by filter
    And I should see at least "10" web search results

    When I follow "Best match"
    Then the "Enter your search term" field should contain "news item"
    And I should see "Last month" within the current time filter
    And I should see "Best match" within the current sort by filter
    And I should see at least "10" web search results

    When I follow "Last hour"
    Then the "Enter your search term" field should contain "news item"
    And I should see "no results found"

    When I follow "Clear"
    And I fill in "Enter your search term" with "body"
    And I press "Search" within the search box
    Then I should see at least "10" web search results
    And I should see "news item 1 body for News-1"
    And I should see "Powered by DIGITALGOV Search"

    When I am on es.agency.gov's "Noticias-1" mobile news search page
    Then I should see "Generado por DIGITALGOV Search"
    And I should see at least "5" web search results

  Scenario: Custom date range news search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     |
      | Spanish site | es.agency.gov | admin@agency.gov | John Bar     | es     |
    And affiliate "en.agency.gov" has the following RSS feeds:
      | name  | url                                  | is_navigable |
      | Press | http://www.whitehouse.gov/feed/press | true         |
    And affiliate "es.agency.gov" has the following RSS feeds:
      | name     | url                                                              | is_navigable |
      | Noticias | http://www.usa.gov/gobiernousa/rss/actualizaciones-articulos.xml | true         |
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

    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "item"
    And I press "Search" within the search box
    And I follow "Press" within the SERP navigation

    When I fill in "From" with "9/30/2012"
    And I fill in "To" with "10/15/2012"
    And I press "Search" within the custom date search form

    Then I should see "Press" within the SERP active navigation
    And the "Enter your search term" field should contain "item"
    And I should see "Sep 30, 2012 - Oct 15, 2012" within the current time filter
    And I should see "Most recent" within the current sort by filter
    And the "From" field should contain "9/30/2012"
    And the "To" field should contain "10/15/2012"
    And I should see a link to "Third item" with url for "http://www.whitehouse.gov/news/3"
    And I should not see a link to "Fourth item"

    When I follow "Best match"
    Then I should see "Press" within the SERP active navigation
    And the "Enter your search term" field should contain "item"
    And I should see "Sep 30, 2012 - Oct 15, 2012" within the current time filter
    And I should see "Best match" within the current sort by filter
    And the "From" field should contain "9/30/2012"
    And the "To" field should contain "10/15/2012"
    And I should see a link to "Third item" with url for "http://www.whitehouse.gov/news/3"
    And I should not see a link to "Fourth item"

    When I follow "Any time"
    Then I should see "Press" within the SERP active navigation
    And the "Enter your search term" field should contain "item"
    And I should see "Any time" within the current time filter
    And I should see "Best match" within the current sort by filter

    When I fill in "From" with "9/30/2012"
    And I fill in "To" with "10/15/2012"
    And I press "Search" within the custom date search form
    And I follow "Best match"
    And I follow "Clear"

    Then I should see "Press" within the SERP active navigation
    And the "Enter your search term" field should contain "item"
    And I should see "Any time" within the current time filter
    And I should see "Most recent" within the current sort by filter

    When I am on es.agency.gov's search page
    And I fill in "Ingrese su búsqueda" with "item"
    And I press "Buscar" within the search box
    And I follow "Noticias" within the SERP navigation

    When I fill in "Desde" with "30/9/2012"
    And I fill in "Hasta" with "15/10/2012"
    And I press "Buscar" within the custom date search form

    Then I should see "Noticias" within the SERP active navigation
    And the "Ingrese su búsqueda" field should contain "item"
    And I should see "sep 30, 2012 - oct 15, 2012" within the current time filter
    And I should see "Más recientes" within the current sort by filter
    And the "Desde" field should contain "30/9/2012"
    And the "Hasta" field should contain "15/10/2012"
    And I should see a link to "Fifth Spanish item" with url for "http://www.gobiernousa.gov/news/5"
    And I should not see a link to "Sixth Spanish item"

    When I follow "Más relevantes"
    Then I should see "Noticias" within the SERP active navigation
    And the "Ingrese su búsqueda" field should contain "item"
    And I should see "sep 30, 2012 - oct 15, 2012" within the current time filter
    And I should see "Más relevantes" within the current sort by filter
    And the "Desde" field should contain "30/9/2012"
    And the "Hasta" field should contain "15/10/2012"
    And I should see a link to "Fifth Spanish item" with url for "http://www.gobiernousa.gov/news/5"
    And I should not see a link to "Sixth Spanish item"

    When I follow "Cualquier fecha"
    Then I should see "Noticias" within the SERP active navigation
    And the "Ingrese su búsqueda" field should contain "item"
    And I should see "Cualquier fecha" within the current time filter
    And I should see "Más relevantes" within the current sort by filter

    When I fill in "Desde" with "30/9/2012"
    And I fill in "Hasta" with "15/10/2012"
    And I press "Buscar" within the custom date search form
    And I follow "Más relevantes"
    And I follow "Borrar"

    Then I should see "Noticias" within the SERP active navigation
    And the "Ingrese su búsqueda" field should contain "item"
    And I should see "Cualquier fecha" within the current time filter
    And I should see "Más recientes" within the current sort by filter

  Scenario: Media RSS search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name |
      | English site | en.agency.gov | admin@agency.gov | John Bar     |
    And affiliate "en.agency.gov" has the following RSS feeds:
      | name   | url                              | is_navigable | show_only_media_content |
      | Images | http://en.agency.gov/feed/images | true         | true                    |
    And there are 10 image news items for "Images"
    When I am on en.agency.gov's "Images" news search page
    And I fill in "Enter your search term" with "image"
    And I press "Search" within the search box
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
    And there are 20 video news items for "usgovernment_channel_id"
    And there are 20 video news items for "whitehouse_channel_id"
    And there are 5 video news items for "gobiernousa_channel_id"

    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "video"
    And I press "Search"
    Then I should see exactly "1" video govbox search result
    And I should see "More videos about video"

    When I follow "Videos" within the SERP navigation
    Then I should see 1 search result title link with url for "http://www.youtube.com/watch?v=0_usgovernment_channel_id"
    And I should see "Powered by DIGITALGOV Search"
    And I should see exactly "20" video search results
    And I should see "Previous"
    And I should see a link to "2" with class "pagination-numbered-link"
    And I should see a link to "Next"

    When I follow "Next"
    Then I should see exactly "20" video search results
    And I should see a link to "Previous"
    And I should see a link to "1" with class "pagination-numbered-link"
    And I should see "Next"

    When I follow "Previous"
    And I follow "2"
    Then I should see exactly "20" video search results

    When I follow "1"
    Then I should see exactly "20" video search results

    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "video usgovernment_channel_id 5"
    And I press "Search"
    Then I should see at least "1" video govbox search result
    And I should not see "More videos about video usgovernment_channel_id 5"

    When I am on es.agency.gov's search page
    And I fill in "Ingrese su búsqueda" with "video"
    And I press "Buscar"
    Then I should see exactly "1" video govbox search results
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
      | GobiernoUSA.gov | https://gobierno.usa.gov |

    When I am on en.agency.gov's "USA.gov" mobile site search page
    And I fill in "Enter your search term" with "gov"
    And I press "Search"
    Then I should see Powered by Bing logo
    And I should see at least "10" web search results

    When I am on es.agency.gov's "GobiernoUSA.gov" mobile site search page
    And I fill in "Ingrese su búsqueda" with "gobierno"
    And I press "Buscar"
    Then I should see Generado por Bing logo
    And I should see at least "7" web search results

  Scenario: Site navigations without dropdown menu
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     |
    And affiliate "en.agency.gov" has the following document collections:
      | name | prefixes             |
      | Blog | http://blog.usa.gov/ |
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

    When I follow "Blog" within the SERP navigation
    And I press "Search"
    Then I should see "Blog" within the SERP active navigation
    And I should see at least "1" web search results

    When I follow "Articles" within the SERP navigation
    Then I should see "Articles" within the SERP active navigation
    And I should see at least "10" web search results

  Scenario: Site navigations with dropdown menu
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale | navigation_dropdown_label |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     | My-awesome-label          |
    And affiliate "en.agency.gov" has the following document collections:
      | name                 | prefixes                | position | is_navigable |
      | FAQs                 | http://answers.usa.gov/ | 0        | true         |
      | Apps                 | http://apps.usa.gov/    | 2        | true         |
      | Inactive site search | http://apps.usa.gov/    | 6        | false        |
    And affiliate "en.agency.gov" has the following RSS feeds:
      | name                 | url                                | is_navigable | position | show_only_media_content | oasis_mrss_name |
      | Articles             | http://en.agency.gov/feed/articles | true         | 1        | false                   |                 |
      | Blog                 | http://en.agency.gov/feed/blog     | true         | 3        | false                   |                 |
      | Media RSS            | http://en.agency.gov/feed/images   | true         | 4        | true                    | 100             |
      | Inactive news search | http://en.agency.gov/feed/news1    | false        | 5        | false                   |                 |
      | News                 | http://en.agency.gov/feed/news2    | true         | 7        | false                   |                 |
    And there are 10 news items for "News"

    When I am on en.agency.gov's mobile search page
    Then I should see "Everything" within the SERP active navigation
    And I fill in "Enter your search term" with "news"
    And I press "Search"

    Then I should see "Everything" within the SERP active navigation
    And I should see "Everything FAQs Articles My-awesome-label Apps Blog News" within the SERP navigation
    And I should see at least "10" web search results

    When I follow "Apps" within the SERP navigation
    Then I should see "Apps" within the SERP active navigation
    And I should see "Everything FAQs Apps My-awesome-label Articles Blog News" within the SERP navigation
    And I should see at least "1" web search results

    When I follow "News" within the SERP navigation
    Then I should see "News" within the SERP active navigation
    And I should see "Everything FAQs News My-awesome-label Articles Apps Blog" within the SERP navigation
    And I should see at least "10" web search results

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
    And I should see an image link to "USAJobs.gov" with url for "https://www.usajobs.gov/"
    And I should see a link to "More federal job openings on USAJobs.gov" with url for "https://www.usajobs.gov/JobSearch/Search/GetResults?PostingChannelID=USASearch"

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
      | 1558        | Alcohol           | https://www.nlm.nih.gov/medlineplus/alcohol.html          | en     | <p>If you are like many Americans, you drink alcohol at least occasionally. For many people, moderate drinking is probably safe.  It may even have health benefits, including reducing your risk of certain heart problems.</p>                                                                                      |
      | 1313        | Underage Drinking | https://www.nlm.nih.gov/medlineplus/underagedrinking.html | en     | <p>It is possible to drink legally and safely - when you're over 21. But if you're under 21, or if you drink too much at any age, alcohol can be especially risky. </p>                                                                                                                                              |
      | 1732        | Alcohol           | https://www.nlm.nih.gov/medlineplus/spanish/alcohol.html  | es     | <p>Si usted es como muchos estadounidenses, quizás consuma bebidas alcohólicas por lo menos ocasionalmente. Para muchas personas, beber moderadamente probablemente sea sano. Quizá hasta puede tener beneficios para la salud, entre los que se incluye disminuir el riesgo de padecer algunos problemas cardiacos. |
    And the following Related Medline Topics for "Alcohol" in English exist:
      | medline_title     | medline_tid | url                                                      |
      | Underage drinking | 1313        | https://www.nlm.nih.gov/medlineplus/underagedrinking.html |
    And the following Related Medline Topics for "Alcohol" in Spanish exist:
      | medline_title | medline_tid | url                                                        |
      | Alcoholismo   | 1733        | https://www.nlm.nih.gov/medlineplus/spanish/alcoholism.html |
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
    Then I should see a link to "Alcohol" with url for "https://www.nlm.nih.gov/medlineplus/alcohol.html" within the med topic govbox
    And I should see a link to "Underage drinking" with url for "https://www.nlm.nih.gov/medlineplus/underagedrinking.html" within the med topic govbox
    And I should see a link to "Alcoholism" with url for "http://clinicaltrials.gov/search/open/condition=%22Alcoholism%22" within the med topic govbox

    When I am on es.agency.gov's mobile search page
    And I fill in "Ingrese su búsqueda" with "alcohol"
    And I press "Buscar"
    Then I should see a link to "Alcohol" with url for "https://www.nlm.nih.gov/medlineplus/spanish/alcohol.html" within the med topic govbox
    And I should see a link to "Alcoholismo" with url for "https://www.nlm.nih.gov/medlineplus/spanish/alcoholism.html" within the med topic govbox

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
      | display_name | name           | contact_email    | contact_name | locale | related_sites_dropdown_label |
      | English site | en.agency.gov  | admin@agency.gov | John Bar     | en     | Search  On                   |
      | All sites    | all.agency.gov | admin@agency.gov | John Bar     | en     |                              |
      | Spanish site | es.agency.gov  | admin@agency.gov | John Bar     | es     |                              |
    And the following Connections exist for the affiliate "en.agency.gov":
      | connected_affiliate | display_name         |
      | es.agency.gov       | Este tema en español |
      | all.agency.gov      | All sites            |
    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "gobierno"
    And I press "Search"
    Then I should see "Search On"
    And I should see a link to "Este tema en español"
    And I should see a link to "All sites"
    When I follow "Este tema en español" within the SERP navigation
    Then I should see the browser page titled "gobierno - Spanish site resultados de la búsqueda"

  Scenario: Searching on sites with federal register documents
    And the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | agency_abbreviation | is_federal_register_document_govbox_enabled | domains  |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | DOC                 | true                                        | noaa.gov |
    And the following Federal Register Document entries exist:
      | federal_register_agencies | document_number | document_type | title                                                              | publication_date | comments_close_in_days | start_page | end_page | page_length | html_url                                                                                                                         |
      | DOC,IRS,ITA,NOAA          | 2014-13420      | Notice        | Proposed Information Collection; Comment Request                   | 2014-06-09       | 7                      | 33040      | 33041    | 2           | https://www.federalregister.gov/articles/2014/06/09/2014-13420/proposed-information-collection-comment-request                   |
      | DOC, NOAA                 | 2013-20176      | Rule          | Atlantic Highly Migratory Species; Atlantic Bluefin Tuna Fisheries | 2013-08-19       |                        | 50346      | 50347    | 2           | https://www.federalregister.gov/articles/2013/08/19/2013-20176/atlantic-highly-migratory-species-atlantic-bluefin-tuna-fisheries |
    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "collection"
    And I press "Search"
    Then I should see a link to "Proposed Information Collection; Comment Request" with url for "https://www.federalregister.gov/articles/2014/06/09/2014-13420/proposed-information-collection-comment-request"
    And I should see "A Notice by the Internal Revenue Service, the International Trade Administration and the National Oceanic and Atmospheric Administration posted on June 9, 2014."
    And I should see "Comment period ends in 7 days"
    And I should see "Pages 33040 - 33041 (2 pages) [FR DOC #: 2014-13420]"

    And I fill in "Enter your search term" with "Tuna"
    And I press "Search"
    Then I should see a link to "Atlantic Highly Migratory Species; Atlantic Bluefin Tuna Fisheries" with url for "https://www.federalregister.gov/articles/2013/08/19/2013-20176/atlantic-highly-migratory-species-atlantic-bluefin-tuna-fisheries"
    And I should see "A Rule by the National Oceanic and Atmospheric Administration posted on August 19, 2013."

  Scenario: English search on a legacy site
    Given the following legacy Affiliates exist:
      | display_name      | name     | contact_email | contact_name |
      | USA.gov           | usagov   | aff@bar.gov   | John Bar     |
    When I am on usagov's overridden search page
    And I fill in "query" with "jobs"
    And I press "Search" in the legacy search box
    Then I should see at least 10 search results

  Scenario: Advanced search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     |
      | Spanish site | es.agency.gov | admin@agency.gov | John Bar     | es     |
    And affiliate "en.agency.gov" has the following RSS feeds:
      | name     | url                                | is_navigable |
      | Articles | http://en.agency.gov/feed/articles | true         |
    And affiliate "es.agency.gov" has the following RSS feeds:
      | name      | url                                | is_navigable |
      | Artículos | http://es.agency.gov/feed/articles | true         |
    When I am on en.agency.gov's advanced search page
    Then I should see "Everything" within the SERP active navigation
    And the "Moderate" radio button should be checked

    When I fill in "All of these words" with "allofit"
    And I fill in "This exact phrase" with "exact"
    And I fill in "Any of these words" with "any"
    And I fill in "None of these words" with "bad"
    And I select "Adobe PDF" from "File Type"
    And I press "Advanced Search"
    And the "Enter your search term" field should contain "allofit \"exact\" \-bad \(any\) filetype:pdf"

  Scenario: SEC Edgar sitelinks
    Given the following Affiliates exist:
      | display_name | name      | contact_email    | contact_name | domains                    |
      | Edgar site   | sec-edgar | admin@agency.gov | John Bar     | www.sec.gov/archives/edgar |
      | News site    | sec-news  | admin@agency.gov | John Bar     | www.sec.gov/news           |
    And affiliate "sec-news" has the following document collections:
      | name  | prefixes               | is_navigable |
      | Edgar | sec.gov/archives/edgar | true         |
    When I am on sec-edgar's search page
    And I fill in "Enter your search term" with "fannie mae"
    And I press "Search"
    Then I should see a link to "Most Recent Filings for this Company"
    And I should see a link to "Full Filing"

    When I am on sec-news's search page
    And I fill in "Enter your search term" with "fannie mae"
    And I press "Search"
    And I follow "Edgar" within the SERP navigation
    Then I should see a link to "Most Recent Filings for this Company"
    And I should see a link to "Full Filing"

  Scenario: Custom page 1 results pointer
    Given the following Affiliates exist:
      | display_name | name           | contact_email    | contact_name | locale | page_one_more_results_pointer |
      | English site | en.agency.gov  | admin@agency.gov | John Bar     | en     | Wherever. <a href="https://duckduckgo.com/?q={QUERY}&ia=about">Try your search again</a> to see results                   |
    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "gov"
    And I press "Search"
    Then I should see "Wherever. Try your search again to see results"

    When I follow "Next"
    Then I should not see "Wherever. Try your search again to see results"

  Scenario: Custom no results pointer
    Given the following Affiliates exist:
      | display_name | name           | contact_email    | contact_name | locale | no_results_pointer |
      | English site | en.agency.gov  | admin@agency.gov | John Bar     | en     | NORESULTS. <a href="https://duckduckgo.com/?q={QUERY}&ia=about">Try your search again</a> to see results                   |
    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "lkssldfkjsldfkjsldkfjsldkjflsdkjflskdjfwer"
    And I press "Search"
    Then I should see "NORESULTS. Try your search again to see results"

  Scenario: Web search on Kalaallisut site
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale | domains              |
      | Kalaallisut site | kl.agency.gov | admin@agency.gov | John Bar     | kl     |                      |
    When I am on kl.agency.gov's mobile search page
    Then I should see "Ujarniakkat ataani allaffissamut allaguk"

  Scenario: Web search using Bing engine
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale | search_engine | domains |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     | Bing          | .gov    |
    And affiliate "en.agency.gov" has the following document collections:
      | name    | prefixes            |
      | USA.gov | https://www.usa.gov |
    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "agency"
    And I press "Search"
    Then I should see at least "10" web search results
    And I should see Powered by Bing logo

    When I follow "USA.gov" within the SERP navigation
    Then I should see "USA.gov" within the SERP active navigation
    And I should see at least "10" web search results
    And I should see Powered by Bing logo

  Scenario: Display an Alert on search page
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale | domains              |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     |                      |
    Given the following Alert exists:
      | affiliate    | text                       | status   | title     |
      | en.agency.gov| New alert for the test aff | Active |  Test Title |
    When I am on en.agency.gov's search page
    Then I should see "New alert for the test aff"
    Given the following Alert exists:
      | affiliate    | text                       | status   | title     |
      | en.agency.gov| New alert for the test aff | Inactive | Test Title |
    When I am on en.agency.gov's search page
    Then I should not see "New alert for the test aff"
