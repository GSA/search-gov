Feature: Searches using mobile device

  Scenario: Web search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     |
      | Spanish site | es.agency.gov | admin@agency.gov | John Bar     | es     |
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
    And the following featured collections exist for the affiliate "en.agency.gov":
      | title                       | title_url                                  | status | publish_start_on | publish_end_on | layout     | image_file_path            |
      | The 21st Century Presidents | http://www.whitehouse.gov/about/presidents | active | 2013-07-01       |                | two column | features/support/small.jpg |
    And the following featured collection links exist for featured collection titled "The 21st Century Presidents":
      | title                           | url                                                                    |
      | 44. Barack Obama                | http://www.whitehouse.gov/about/presidents/barackobama                 |
      | 43. George W. Bush              | http://www.whitehouse.gov/about/presidents/georgewbush                 |
      | The Presidents Photo Galleries  | http://www.whitehouse.gov/photos-and-video/photogallery/the-presidents |
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
    And I should see "44. Barack Obama The Presidents Photo Galleries 43. George W. Bush"
    And I should see "Show more"
    And I should see "Show less"
    And I should see at least "2" web search results
    And I should see 2 related searches

    When I am on es.agency.gov's mobile search page
    And I fill in "Ingrese su búsqueda" with "presidente"
    And I press "Buscar"
    Then I should see Accionado por Bing logo
    And I should see 3 Best Bets Texts
    And I should see "Mostrar más"
    And I should see "Mostrar menos"
    And I should see at least "2" web search results

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
    Then I should see "Powered by USASearch"
    And I should see at least "10" web search results

    When I am on es.agency.gov's "Noticias-1" mobile news search page
    Then I should see "Accionado por USASearch"
    And I should see at least "5" web search results

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
    Then I should see Accionado por Bing logo
    And I should see at least "10" web search results
