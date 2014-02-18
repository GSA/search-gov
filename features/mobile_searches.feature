Feature: Searches using mobile device

  Scenario: Web search
    Given the following Affiliates exist:
      | display_name | name          | contact_email    | contact_name | locale | domains        |
      | English site | en.agency.gov | admin@agency.gov | John Bar     | en     |                |
      | Spanish site | es.agency.gov | admin@agency.gov | John Bar     | es     |                |
      | Hippo site   | hippo         | admin@agency.gov | John Bar     | en     | whitehouse.gov |
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
      | title                       | title_url                                  | status | publish_start_on | publish_end_on | layout     | image_file_path            |
      | The 21st Century Presidents | http://www.whitehouse.gov/about/presidents | active | 2013-07-01       |                | two column | features/support/small.jpg |
    And the following featured collection links exist for featured collection titled "The 21st Century Presidents":
      | title                           | url                                                                    |
      | 44. Barack Obama                | http://www.whitehouse.gov/about/presidents/barackobama                 |
      | 43. George W. Bush              | http://www.whitehouse.gov/about/presidents/georgewbush                 |
      | The Presidents Photo Galleries  | http://www.whitehouse.gov/photos-and-video/photogallery/the-presidents |
    And the following Twitter Profiles exist:
      | screen_name | name          | twitter_id | affiliate     |
      | USASearch   | USASearch.gov | 123        | en.agency.gov |
    And the following Tweets exist:
      | tweet_text                                                                                    | tweet_id | published_ago | twitter_profile_id | url                    | expanded_url            | display_url      |
      | President Obama: "Don’t Just Play on Your Phone, Program It"                                  | 234567   | week          | 123                |                        |                         |                  |
      | "We wish you all a blessed and safe holiday season." - President Obama http://t.co/l8jbZSbmAX | 184957   | hour          | 123                | http://t.co/l8jbZSbmAX | http://go.wh.gov/sgCp3q | go.wh.gov/sgCp3q |
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
    Then I should see Accionado por Bing logo
    And I should see 3 Best Bets Texts
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
    Then I should see "Accionado por DIGITALGOV Search"
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

    When I follow "FAQs"
    And I press "Search"
    Then I should see "FAQs" within the SERP active navigation
    And I should see at least "10" web search results

    When I follow "Articles"
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
      | Media RSS            | http://en.agency.gov/feed/Images   | true         | 4        | true                    |
      | Inactive news search | http://en.agency.gov/feed/News     | false        | 5        | false                   |
      | News                 | http://en.agency.gov/feed/News     | true         | 7        | false                   |
    And there are 10 news items for "News"

    When I am on en.agency.gov's mobile search page
    Then I should see "Everything" within the SERP active navigation
    And I fill in "Enter your search term" with "news"
    And I press "Search"

    Then I should see "Everything" within the SERP active navigation
    And I should see "Everything FAQs Articles More Apps Blog News" within the SERP navigation
    And I should see at least "10" web search results

    When I follow "Apps"
    Then I should see "Apps" within the SERP active navigation
    And I should see "Everything FAQs Apps More Articles Blog News" within the SERP navigation
    And I should see at least "10" web search results

    When I follow "News"
    Then I should see "News" within the SERP active navigation
    And I should see "Everything FAQs News More Articles Apps Blog" within the SERP navigation
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
    And I should see a link to "See all federal job openings" with url for "https://www.usajobs.gov/JobSearch/Search/GetResults?PostingChannelID=USASearch"
