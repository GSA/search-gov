# DO NOT ADD NEW TESTS TO THIS FILE!
# New tests should be added to searches.feature.
# The separate files are a leftover from the days of the legacy SERP.
# We are preserving this old file for sake of future git blame-rs.

Feature: Searches using mobile device
  Scenario: Web search
    Given the following BingV7 Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | locale | domains              | use_redesigned_results_page | search_engine |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar     | en       |                      | false                       | bing_v7       |
      | Spanish site | es.agency.gov | admin@agency.gov | John       | Bar     | es       |                      | false                       | bing_v7       |
      | Hippo site   | hippo         | admin@agency.gov | John       | Bar     | en       | hippo.whitehouse.gov | false                       | bing_v7       |
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
      | Presidente Barack Obama: ganador elecciones de 2012 | https://www.usa.gov/gobiernousa/Temas/Votaciones/Presidente-Barack-Obama.shtml |
      | Servicios por Internet                              | https://www.usa.gov/gobiernousa/Temas/Servicios.shtml                          |
      | Seguros de salud                                    | https://www.usa.gov/gobiernousa/Salud-Nutricion-Seguridad/Salud/Seguros.shtml  |
    And the following SAYT Suggestions exist for en.agency.gov:
      | phrase                 |
      | president list         |
      | president inauguration |
    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "president"
    And I press "Search"
    Then I should see Powered by Bing logo
    And I should see 1 Best Bets Texts
    And I should see 1 Best Bets Graphic
    And I should see "44. Barack Obama 43. George W. Bush The Presidents Photo Galleries"
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

    When I am on es.agency.gov's search page
    And I fill in "Ingrese su búsqueda" with "presidente"
    And I press "Buscar"
    Then I should see Generado por Bing logo
    And I should see 1 Best Bets Texts
    And I should see 1 Best Bets Graphic
    And I should see at least "2" web search results

    When I am on hippo's search page
    And I fill in "Enter your search term" with "hippopotamus"
    And I press "Search"
    Then I should see "Sorry, no results found for 'hippopotamus'."
    And I should see "Hippopotamus amphibius"

  Scenario: Collections search
    Given the following BingV7 Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | locale | use_redesigned_results_page | search_engine |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en     | false                       | BingV7        |
      | Spanish site | es.agency.gov | admin@agency.gov | John       | Bar       | es     | false                       | BingV7        |

    And affiliate "en.agency.gov" has the following document collections:
      | name    | prefixes            |
      | USA.gov | https://www.usa.gov |

    And affiliate "es.agency.gov" has the following document collections:
      | name         | prefixes                     |
      | Gobierno USA | https://www.usa.gov/espanol/ |

    When I am on en.agency.gov's "USA.gov" docs search page
    And I fill in "Enter your search term" with "gov"
    And I press "Search"
    Then I should see Powered by Bing logo
    And I should see at least "10" web search results
    And every result URL should match "www.usa.gov"

    When I am on es.agency.gov's "Gobierno USA" docs search page
    And I fill in "Ingrese su búsqueda" with "gobierno"
    And I press "Buscar"
    Then I should see Generado por Bing logo
    And I should see at least "7" web search results
    And every result URL should match "www.usa.gov/espanol"

  Scenario: Site navigations without dropdown menu
    Given the following BingV7 Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | locale | use_redesigned_results_page | search_engine |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en     | false                       | bing_v7       |
    And affiliate "en.agency.gov" has the following document collections:
      | name | prefixes             |
      | Blog | http://blog.usa.gov/ |
    When I am on en.agency.gov's search page
    Then I should see "Everything" within the SERP active navigation

    When I fill in "Enter your search term" with "news"
    And I press "Search"
    Then I should see "Everything" within the SERP active navigation
    And I should see at least "10" web search results

    When I follow "Blog" within the SERP navigation
    And I press "Search"
    Then I should see "Blog" within the SERP active navigation
    And I should see at least "1" web search results

  Scenario: Site navigations with dropdown menu
    Given the following BingV7 Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | locale | navigation_dropdown_label | use_redesigned_results_page | search_engine |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en     | My-awesome-label          | false                       | bing_v7       |
    And affiliate "en.agency.gov" has the following document collections:
      | name                 | prefixes                 | position | is_navigable |
      | FAQs                 | http://answers.usa.gov/  | 0        | true         |
      | Articles             | https://www.usa.gov      | 1        | true         |
      | Apps                 | https://www.data.gov     | 2        | true         |
      | Blog                 | https://search.gov/blog/ | 3        | true         |
      | Inactive site search | http://apps.usa.gov/     | 6        | false        |
      | News                 | https://www.usa.gov/news | 7        | true         |

    When I am on en.agency.gov's search page
    Then I should see "Everything" within the SERP active navigation
    And I fill in "Enter your search term" with "news"
    And I press "Search"

    Then I should see "Everything" within the SERP active navigation
    And I should see "Everything FAQs Articles My-awesome-label Apps Blog News" within the SERP navigation
    And I should see at least "10" web search results

    When I follow "News" within the SERP navigation
    Then I should see "News" within the SERP active navigation
    And I should see "Everything FAQs News My-awesome-label Articles Apps Blog" within the SERP navigation

    When I follow "Apps" within the SERP navigation
    Then I should see "Apps" within the SERP active navigation
    And I should see "Everything FAQs Apps My-awesome-label Articles Blog News" within the SERP navigation
    And I fill in "Enter your search term" with "app"
    And I press "Search"
    And I should see at least "1" web search results

    When I am on en.agency.gov's "Inactive site search" docs search page
    Then I should see "Inactive site search" within the SERP active navigation

  Scenario: Job search
    Given the following BingV7 Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name |locale | jobs_enabled | use_redesigned_results_page | search_engine |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en    | 1            | false                       | bing_v7       |
      | Spanish site | es.agency.gov | admin@agency.gov | John       | Bar       | es    | 1            | false                       | bing_v7       |

    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "jobs"
    And I press "Search"
    Then I should see "Federal Job Openings"
    And I should see at least 10 job postings
    And I should see an annual salary
    And I should see an application deadline
    And I should see an image link to "USAJobs.gov" with url for "https://www.usajobs.gov/"
    And I should see a link to "More federal job openings on USAJobs.gov" with url for "https://www.usajobs.gov/Search/Results?hp=public"

    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "blablah jobs"
    And I press "Search"
    Then I should see an image link to "USAJobs.gov" with url for "https://www.usajobs.gov/"
    And I should see "No job openings in your region match your search"
    And I should see a link to "More federal job openings on USAJobs.gov" with url for "https://www.usajobs.gov/Search/Results?hp=public"

    When I am on es.agency.gov's search page
    And I fill in "Ingrese su búsqueda" with "blablah trabajo"
    And I press "Buscar"
    Then I should see an image link to "USAJobs.gov" with url for "https://www.usajobs.gov/"
    And I should see "Ninguna oferta de trabajo en su región coincide con su búsqueda"
    And I should see a link to "Más trabajos en el gobierno federal en USAJobs.gov" with url for "https://www.usajobs.gov/Search/Results?hp=public"

  Scenario: Agency job search
    Given the following Agencies exist:
      | name                            | abbreviation | organization_codes |
      | General Services Administration | GSA          | GS                 |
    And the following BingV7 Affiliates exist:
      | display_name | name       | agency_abbreviation | jobs_enabled | contact_email                | use_redesigned_results_page | search_engine |
      | English site | agency.gov | GSA                 | true         | affiliate_admin@fixtures.org | false                       | BingV7        |
    When I am on agency.gov's search page
    And I search for "jobs"
    Then I should see "Job Openings at GSA"
    And I should see at least 1 job posting
    And I should see a link to "More GSA job openings on USAJobs.gov" with url for "https://www.usajobs.gov/Search/Results?a=GS&hp=public"

  Scenario: Searching with sitelimit
    Given the following BingV7 Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | locale | domains | use_redesigned_results_page | search_engine |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en     | .gov    | false                       | BingV7        |
      | Spanish site | es.agency.gov | admin@agency.gov | John       | Bar       | es     | .gov    | false                       | BingV7        |
    And affiliate "en.agency.gov" has the following document collections:
      | name | prefixes                 | is_navigable |
      | Blog | https://search.gov/blog/ | true         |
    When I am on en.agency.gov's search page with site limited to "usa.gov"
    And I search for "gov"
    Then every result URL should match "usa.gov"
    Then I should see "We're including results for gov from usa.gov only."
    And I should see "Do you want to see results for gov from all locations?"
    When I follow "gov from all locations" within the search all sites row
    Then I should not see "We're including results for gov from usa.gov only."
    When I follow "Blog" in the search navbar
    Then I should see at least "1" web search results
    And every result URL should match "search.gov/blog"

    When I am on es.agency.gov's search page with site limited to "usa.gov"
    And I fill in "Ingrese su búsqueda" with "gobierno"
    And I press "Buscar"
    Then every result URL should match "usa.gov"
    And I should see "Los resultados para gobierno son solo de usa.gov."
    And I should see "¿Quiere ver resultados para gobierno de todos los sitios?"
    When I follow "gobierno de todos los sitios" within the search all sites row
    Then I should not see "Los resultados para gobierno son solo de usa.gov."

  Scenario: Searching on sites with related sites
    Given the following BingV7 Affiliates exist:
      | display_name | name           | contact_email    | first_name | last_name | locale | related_sites_dropdown_label | use_redesigned_results_page | search_engine |
      | English site | en.agency.gov  | admin@agency.gov | John       | Bar       | en     | Search  On                   | false                       | BingV7        |
      | All sites    | all.agency.gov | admin@agency.gov | John       | Bar       | en     |                              | false                       | BingV7        |
      | Spanish site | es.agency.gov  | admin@agency.gov | John       | Bar       | es     |                              | false                       | BingV7        |
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
    And the following BingV7 Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | agency_abbreviation | is_federal_register_document_govbox_enabled | domains  | use_redesigned_results_page | search_engine |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | DOC                 | true                                        | noaa.gov | false                       | BingV7        |
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

  Scenario: Custom page 1 results pointer
    Given the following BingV7 Affiliates exist:
      | display_name | name           | contact_email    | first_name | last_name | locale | page_one_more_results_pointer                                                                           | use_redesigned_results_page | search_engine |
      | English site | en.agency.gov  | admin@agency.gov | John       | Bar       | en     | Wherever. <a href="https://duckduckgo.com/?q={QUERY}&ia=about">Try your search again</a> to see results | false                       | BingV7        |
    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "gov"
    And I press "Search"
    Then I should see "Wherever. Try your search again to see results"

    When I follow "Next"
    Then I should not see "Wherever. Try your search again to see results"

  Scenario: Custom no results pointer
    Given the following BingV7 Affiliates exist:
      | display_name | name           | contact_email    | first_name   | last_name | locale | no_results_pointer                                                                                       | use_redesigned_results_page | search_engine |
      | English site | en.agency.gov  | admin@agency.gov | John         | Bar       | en     | NORESULTS. <a href="https://duckduckgo.com/?q={QUERY}&ia=about">Try your search again</a> to see results | false                       | BingV7        |
    When I am on en.agency.gov's search page
    And I fill in "Enter your search term" with "lkssldfkjsldfkjsldkfjsldkjflsdkjflskdjfwer"
    And I press "Search"
    Then I should see "NORESULTS. Try your search again to see results"

  Scenario: Web search on Kalaallisut site
    Given the following BingV7 Affiliates exist:
      | display_name     | name          | contact_email    | first_name | last_name | locale | domains              | use_redesigned_results_page | search_engine |
      | Kalaallisut site | kl.agency.gov | admin@agency.gov | John       | Bar       | kl     |                      | false                       | BingV7        |
    When I am on kl.agency.gov's search page
    Then I should see "Ujarniakkat ataani allaffissamut allaguk"

  Scenario: Web search using Bing engine
    Given the following BingV7 Affiliates exist:
      | display_name | name          | contact_email    | first_name   | last_name | locale | search_engine | domains | use_redesigned_results_page |
      | English site | en.agency.gov | admin@agency.gov | John         | Bar       | en     | BingV7        | .gov    | false                       |
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

  Scenario: Active facet display using SearchGov
    Given the following BingV7 Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | locale | search_engine | domains | use_redesigned_results_page |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en     | SearchGov     | .gov    | false                       |
    And affiliate "en.agency.gov" has the following document collections:
      | name    | prefixes            |
      | USA.gov | https://www.usa.gov |
    When I am on en.agency.gov's search page
    And I follow "USA.gov" within the SERP navigation
    Then I should see the "USA.gov" Collection as the active facet

  Scenario: Display an Alert on search page
    Given the following BingV7 Affiliates exist:
      | display_name | name          | contact_email    | first_name | last_name | locale | domains              | use_redesigned_results_page | search_engine |
      | English site | en.agency.gov | admin@agency.gov | John       | Bar       | en     |                      | false                       | BingV7        |
    Given the following Alert exists:
      | affiliate    | text                       | status   | title     |
      | en.agency.gov| New alert for the test aff | Active   |  Test Title |
    When I am on en.agency.gov's search page
    Then I should see "New alert for the test aff"
    Given the following Alert exists:
      | affiliate    | text                       | status   | title      |
      | en.agency.gov| New alert for the test aff | Inactive | Test Title |
    When I am on en.agency.gov's search page
    Then I should not see "New alert for the test aff"
