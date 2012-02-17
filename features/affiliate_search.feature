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

  Scenario: Searching with active RSS feeds
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                                | is_active |
      | Press         | http://www.whitehouse.gov/feed/press               | true      |
      | Photo Gallery | http://www.whitehouse.gov/feed/media/photo-gallery | true      |
      | Hide Me       | http://www.whitehouse.gov/feed/media/photo-gallery | false     |
    And feed "Press" has the following news items:
    | link                             | title       | guid  | published_ago | description                  |
    | http://www.whitehouse.gov/news/1 | First item  | uuid1 | day           | First news item for the feed |
    | http://www.whitehouse.gov/news/2 | Second item | uuid2 | day           | Next news item for the feed  |
    And feed "Photo Gallery" has the following news items:
    | link                             | title       | guid  | published_ago | description                  |
    | http://www.whitehouse.gov/news/3 | Third item  | uuid3 | week          | More news items for the feed |
    | http://www.whitehouse.gov/news/4 | Fourth item | uuid4 | week          | Last news item for the feed  |
    And the following SAYT Suggestions exist for bar.gov:
    | phrase                 |
    | Some Unique item |
    | el paso term           |
    When I am on bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search"
    Then I should see "Everything"
    And I should see "Images"
    And I should see "Press"
    And I should see "Photo Gallery"
    And I should not see "Hide Me"
    And I should not see "All Time"
    And I should not see "Last hour"
    And I should not see "Last day"
    And I should not see "Last week"
    And I should not see "Last month"
    And I should not see "Last year"

    When I follow "Press"
    And I follow "Last week"
    Then I should see "First news item for the feed"
    And I should see "Next news item for the feed"
    And I should not see "More news items for the feed"
    And I should not see "Last news item for the feed"
    And I should see "Related Searches" in the search results section
    And I should see "Search" button

    When I follow "Photo Gallery"
    Then I should see "no results found for 'item'"

    When I follow "All Time"
    Then I should see "More news items for the feed"
    And I should see "Last news item for the feed"

    When I follow "Last hour"
    Then I should see "no results found for 'item'"

    When I follow "Everything"
    Then I should see "Advanced Search"
    And I should see "Search" button

    When I am on bar.gov's Spanish search page
    And I fill in "query" with "president"
    And I press "Buscar"
    Then I should see "Resultados 1-10"
    And I should see "Todo"
    And I should not see "Everything"
    And I should see "Imágenes"
    And I should not see "Images"
    And I should not see "Search this site"
    And I should not see "Cualquier fecha"
    And I should not see "All Time"

    When I follow "Press"
    Then I should see "Cualquier fecha"

  Scenario: No results when searching with active RSS feeds
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     |
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                                | is_active |
      | Press         | http://www.whitehouse.gov/feed/press               | true      |
      | Photo Gallery | http://www.whitehouse.gov/feed/media/photo-gallery | true      |
    And feed "Photo Gallery" has the following news items:
      | link                             | title       | guid  | published_ago | description                  |
      | http://www.whitehouse.gov/news/3 | Third item  | uuid3 | week          | More news items for the feed |
      | http://www.whitehouse.gov/news/4 | Fourth item | uuid4 | week          | Last news item for the feed  |
    When I am on bar.gov's search page
    And I fill in "query" with "item"
    And I press "Search"
    Then I should see "Results 1-10"

    When I follow "Press"
    Then I should see "Sorry, no results found for 'item'. Remove all filters or try entering fewer or broader query terms."
    When I follow "Remove all filters"
    Then I should see "Results 1-10"

    When I fill in "query" with "item"
    And I press "Search"
    And I follow "Photo Gallery"
    Then I should see "More news items for the feed"
    When I follow "Last day"
    Then I should see "Sorry, no results found for 'item' in the last day. Remove all filters or try entering fewer or broader query terms."
    When I follow "Remove all filters"
    Then I should see "Results 1-10"

  Scenario: No results when searching with active RSS feeds in Spanish
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     |
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                                | is_active |
      | Press         | http://www.whitehouse.gov/feed/press               | true      |
      | Photo Gallery | http://www.whitehouse.gov/feed/media/photo-gallery | true      |
    And feed "Photo Gallery" has the following news items:
      | link                             | title       | guid  | published_ago | description                  |
      | http://www.whitehouse.gov/news/3 | Third item  | uuid3 | week          | More news items for the feed |
      | http://www.whitehouse.gov/news/4 | Fourth item | uuid4 | week          | Last news item for the feed  |
    When I am on bar.gov's Spanish search page
    And I fill in "query" with "item"
    And I press "Buscar"
    Then I should see "Resultados 1-10"

    When I follow "Press"
    Then I should see "No hemos encontrado ningún resultado que contenga 'item'. Elimine los filtros de su búsqueda, use otras palabras clave o intente usando sinónimos."
    When I follow "Elimine los filtros"
    Then I should see "Resultados 1-10"

    When I fill in "query" with "item"
    And I press "Buscar"
    And I follow "Photo Gallery"
    And I follow "Último día"
    Then I should see "No hemos encontrado ningún resultado que contenga 'item' en el último día. Elimine los filtros de su búsqueda, use otras palabras clave o intente usando sinónimos."
    When I follow "Elimine los filtros"
    Then I should see "Resultados 1-10"

  Scenario: Visiting English affiliate search with multiple domains
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains                |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | whitehouse.gov,usa.gov |
    When I am on bar.gov's search page
    And I fill in "query" with "president"
    And I press "Search"
    Then I should see "Results 1-10"
    And I should not see "Search this site"

  Scenario: Visiting Spanish affiliate search with multiple domains
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | domains                |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | whitehouse.gov,usa.gov |
    When I am on bar.gov's Spanish search page
    And I fill in "query" with "president"
    And I press "Buscar"
    Then I should see "Resultados 1-10"
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

  Scenario: Searchers see agency popular pages in English
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
    And the following Agency Popular Urls exist:
      | name | locale | rank | title                                 | url                                                |
      | SSA  | en     | 20   | Get or replace a Social Security card | http://www.ssa.gov/ssnumber/                       |
      | SSA  | en     | 10   | Apply online for retirement benefits  | http://www.ssa.gov/planners/about.htm              |
      | SSA  | es     | 20   | Solicite beneficios de jubilación     | http://www.ssa.gov/espanol/plan/sobreelplan.htm    |
      | SSA  | es     | 10   | Solicite beneficios de incapacidad    | http://www.ssa.gov/espanol/soliciteporincapacidad/ |
    And I am logged in with email "aff@agency.gov" and password "random_string"
    When I am on ssa.gov's search page
    And I fill in "query" with "ssa"
    And I press "Search"
    Then I should see a link to "Get or replace a Social Security card" with url for "http://www.ssa.gov/ssnumber/" on the popular pages list
    And I should see a link to "Apply online for retirement benefits" with url for "http://www.ssa.gov/planners/about.htm" on the popular pages list
    And I should not see a link to "Solicite beneficios de jubilación" with url for "http://www.ssa.gov/espanol/plan/sobreelplan.htm" on the popular pages list
    And I should not see a link to "Solicite beneficios de incapacidad" with url for "http://www.ssa.gov/espanol/soliciteporincapacidad/" on the popular pages list

    When I go to the affiliate admin page with "ssa.gov" selected
    And I follow "Look and feel"
    And I uncheck "Show Agency Govbox?"
    And I press "Update"

    When I am on ssa.gov's search page
    And I fill in "query" with "ssa"
    And I press "Search"
    Then I should not see a link to "Get or replace a Social Security card" with url for "http://www.ssa.gov/ssnumber/" on the popular pages list
    And I should not see a link to "Apply online for retirement benefits" with url for "http://www.ssa.gov/planners/about.htm" on the popular pages list

  Scenario: Searchers see agency popular pages in Spanish
    Given the following Affiliates exist:
      | display_name    | name        | contact_email | contact_name | locale | is_agency_govbox_enabled |
      | GobiernoUSA.gov | gobiernousa | aff@bar.gov   | John Bar     | es     | true                     |
    And the following Agency entries exist:
      | name | domain  |
      | SSA  | ssa.gov |
    And the following Agency Urls exist:
      | name | locale | url                         |
      | SSA  | en     | http://www.ssa.gov/         |
      | SSA  | es     | http://www.ssa.gov/espanol/ |
    And the following Agency Popular Urls exist:
      | name | locale | rank | title                                 | url                                                |
      | SSA  | en     | 20   | Get or replace a Social Security card | http://www.ssa.gov/ssnumber/                       |
      | SSA  | en     | 10   | Apply online for retirement benefits  | http://www.ssa.gov/planners/about.htm              |
      | SSA  | es     | 20   | Solicite beneficios de jubilación     | http://www.ssa.gov/espanol/plan/sobreelplan.htm    |
      | SSA  | es     | 10   | Solicite beneficios de incapacidad    | http://www.ssa.gov/espanol/soliciteporincapacidad/ |
    When I am on gobiernousa's search page
    And I fill in "query" with "ssa"
    And I press "Buscar"
    Then I should see a link to "Solicite beneficios de jubilación" with url for "http://www.ssa.gov/espanol/plan/sobreelplan.htm" on the popular pages list
    And I should see a link to "Solicite beneficios de incapacidad" with url for "http://www.ssa.gov/espanol/soliciteporincapacidad/" on the popular pages list
    And I should not see a link to "Get or replace a Social Security card" with url for "http://www.ssa.gov/ssnumber/" on the popular pages list
    And I should not see a link to "Apply online for retirement benefits" with url for "http://www.ssa.gov/planners/about.htm" on the popular pages list

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
    And I follow "Look and feel"
    And I uncheck "Show Medline Govbox?"
    And I press "Update"

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
    And I follow "Look and feel"
    And I uncheck "Show Medline Govbox?"
    And I press "Update"

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
      | url                       | affiliate | title       | description     |
      | http://nih.gov/1.html     | nih.gov   | NIH Page 1  | This is page 1  |
      | http://nih.gov/2.html     | nih.gov   | NIH Page 2  | This is page 2  |
    And the url "http://nih.gov/1.html" has been crawled
    And the url "http://nih.gov/2.html" has been crawled
    And I am on nih.gov's search page
    And I fill in "query" with "NIH"
    And I press "Search"
    Then I should see "NIH Page 1" in the indexed documents section
    And I should see "NIH Page 2" in the indexed documents section

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
