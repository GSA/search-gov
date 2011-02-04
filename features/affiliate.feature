Feature: Affiliate clients
  In order to give my searchers a custom search experience
  As an affiliate
  I want to see and manage my affiliate settings

  Scenario: Visiting the affiliate welcome/list page as a un-authenticated Affiliate
    When I go to the affiliate welcome page
    Then I should see "USASearch > Affiliate Program"
    And I should see "Hosted Search Services"
    Then I should see "Affiliate Program"
    And I should see "APIs & Web Services"
    And I should see "Search.USA.gov"
    And I should not see "USA Search Program"
    And I should not see "Admin Center"
    And I should not see "Analyst Center"
    And I should not see "Affiliate Center"
    And I should not see "Developer"

    When I follow "Register Now"
    Then I should see "Sign In to Use Our Services"

  Scenario: Visiting the affiliate welcome page as affiliate admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the affiliate welcome page
    Then I should see "Admin Center"
    And I should not see "Analyst Center"
    And I should not see "Affiliate Center"
    Then I should see "USASearch > Affiliate Program"

  Scenario: Visiting the affiliate welcome page as affiliate
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the affiliate welcome page
    Then I should see "Affiliate Center" within ".secondary-navbar"
    And I should not see "Admin Center"
    And I should not see "Analyst Center"
    And I should see "USASearch > Affiliate Program"

  Scenario: Visiting the affiliate admin page as affiliate
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    Then I should see "USASearch > Affiliate Program > Affiliate Center"

  Scenario: Visiting the account page as a logged-in user with affiliates
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | multi1 site      | multi1.gov       | two@bar.gov           | Two Bar             |
      | multi2 site      | multi2.gov       | two@bar.gov           | Two Bar             |
    And I am logged in with email "two@bar.gov" and password "random_string"
    When I go to the user account page
    Then I should see "multi1 site"
    And I should see "multi2 site"
    When I follow "Affiliate Center"
    Then I should see "multi1 site" within ".admin-table"
    And I should see "multi2 site" within ".admin-table"
    And I should not see "multi1.gov"
    And I should not see "multi2.gov"

  Scenario: Adding a new affiliate
    Given I am logged in with email "affiliate_with_no_contact_info@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Affiliate"
    Then I should see "USASearch > Affiliate Program > Affiliate Center > Add New Site"
    And I should see "Add a New Site"
    And I should see "Step 1. Enter contact information" within ".current_step"
    And I should see "Contact information"
    And the "Name*" field should contain "A New Affiliate"
    And the "Email*" field should contain "affiliate_with_no_contact_info@fixtures.org"
    And I fill in the following:
      | Government organization                    | Awesome Agency             |
      | Phone                                      | 202-123-4567               |
      | Organization address                       | 123 Penn Avenue            |
      | Address 2                                  | Ste 456                    |
      | City                                       | Reston                     |
      | Zip                                        | 20022                      |
    And I select "Virginia" from "State"
    And I press "Next"
    Then I should see "Step 2. Set up site" within ".current_step"
    And I should see "Site information"
    And I fill in the following:
      | Site name                 | My awesome agency                |
      | Domains to search         | www.awesomeagency.gov            |
    And I press "Next"
    And I should see "Site successfully created"
    And I should see "Step 3. Get the code" within ".current_step"
    And I should see "View search results page"
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should see "Search results for My awesome agency"

  Scenario: Affiliate user who filled out contact information should not have to fill out the form again
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Affiliate"
    Then I should see "USASearch > Affiliate Program > Affiliate Center > Add New Site"
    And I should see "Add a New Site"
    And I should see "Step 1. Enter contact information" within ".current_step"
    And I should see "Contact information"
    And the "Name*" field should contain "A New Manager"
    And the "Email*" field should contain "affiliate_manager_with_no_affiliates@fixtures.org"
    And the "Government organization*" field should contain "Agency"
    And the "Phone*" field should contain "301-123-4567"
    And the "Organization address*" field should contain "123 Penn Ave"
    And the "Address 2" field should contain "Ste 100"
    And the "City*" field should contain "Reston"
    And the "State*" field should contain "VA"
    And the "Zip*" field should contain "20022"
    And I press "Next"
    Then I should see "Step 2. Set up site" within ".current_step"

  Scenario: Clicking on Adding additional sites in Step 3. Get the code
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "new"
    And I press "Next"
    And I fill in the following:
      | Site name                 | My awesome agency                |
    And I press "Next"
    And I follow "Adding additional sites"
    Then I should see "USASearch > Affiliate Program > Affiliate Center > Add New Site"

  Scenario: Clicking on Customizing the look and feel in Step 3. Get the code
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "new"
    And I press "Next"
    And I fill in the following:
      | Site name                 | My awesome agency                |
    And I press "Next"
    And I follow "Customizing the look and feel"
    Then I should see "USASearch > Affiliate Program > Affiliate Center > My awesome agency > Edit"

  Scenario: Clicking on Setting up the type-ahead search in Step 3. Get the code
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "new"
    And I press "Next"
    And I fill in the following:
      | Site name                 | My awesome agency                |
    And I press "Next"
    And I follow "Setting up the type-ahead search"
    Then I should see "USASearch > Affiliate Program > Affiliate Center > My awesome agency > Type-ahead Search"

  Scenario: Clicking on Go to Affiliate Center in Step 3. Get the code
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "new"
    And I press "Next"
    And I fill in the following:
      | Site name                 | My awesome agency                |
    And I press "Next"
    And I follow "Go to Affiliate Center"
    Then I should be on the affiliate admin page

  Scenario: Updating HTTP parameter site name
    Given the following Affiliates exist:
      | display_name      | name              | contact_email         | contact_name        |
      | aff site1         | aff1.gov          | aff@bar.gov           | John Bar            |
      | aff site2         | aff2.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site2"
    And I follow "Edit"
    And I fill in "HTTP parameter site name" with "aff-01_2011.gov"
    And I press "Save for preview"
    Then I should see "Staged changes to your affiliate successfully."
    And I follow "aff site2"
    And I follow "Edit"
    And the "HTTP parameter site name" field should contain "aff-01_2011.gov"

  Scenario: Editing an affiliate with problems
    Given the following Affiliates exist:
      | display_name      | name              | contact_email         | contact_name        |
      | aff site1         | aff1.gov          | aff@bar.gov           | John Bar            |
      | aff site2         | aff2.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "aff site2"
    And I follow "Edit"
    And I fill in "HTTP parameter site name" with "aff1.gov"
    And I press "Save for preview"
    Then I should see "HTTP parameter site name has already been taken"

  Scenario: Adding an affiliate without filling out contact information should fail
    Given I am logged in with email "affiliate_with_no_contact_info@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "new"
    And I press "Next"
    Then I should see "Organization name can't be blank"
    Then I should see "Phone can't be blank"
    Then I should see "Address can't be blank"
    Then I should see "City can't be blank"
    Then I should see "Zip can't be blank"

  Scenario: Adding an affiliate without site display name should fail
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "new"
    And I press "Next"
    And I press "Next"
    Then I should see "Site name can't be blank"
    And I should not see "HTTP parameter site name can't be blank"
    And I should not see "HTTP parameter site name is too short"
    And I should not see "HTTP parameter site name is invalid"

  Scenario: Deleting an affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I press "Delete Affiliate"
    Then I should be on the affiliate admin page
    And I should see "Affiliate deleted"

  Scenario: Staging changes to an affiliate's look and feel
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        | domains        | header      | footer      | staged_domains  | staged_header    | staged_footer  |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            | oldagency.gov  | Old header  | Old footer  | oldagency.gov    | Old header      | Old footer    |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "Edit"
    Then I should see "USASearch > Affiliate Program > Affiliate Center > aff site > Edit"
    And the "Domains (one per line)" field should contain "oldagency.gov"
    And the "Enter HTML to customize the top of your search page" field should contain "Old header"
    And the "Enter HTML to customize the bottom of your search page" field should contain "Old footer"
    When I fill in the following:
      | Site name                                                             | new site name                                       |
      | HTTP parameter site name                                              | newname                                             |
      | Your Website URL (www.example.gov)                                    | www.agency.gov                                      |
      | Domains (one per line)                                                | newagency.gov                                       |
      | Enter HTML to customize the top of your search page                   | New header                                          |
      | Enter HTML to customize the bottom of your search page                | New footer                                          |
    And I select "Basic Gray (A simple, clean gray page)" from "Style for your search page results"
    And I press "Save for preview"
    Then I should see "Staged changes to your affiliate successfully."
    And I should be on the affiliate admin page
    And I should see "new site name"
    When I follow "Edit"
    Then the "Domains (one per line)" field should contain "newagency.gov"
    And the "Enter HTML to customize the top of your search page" field should contain "New header"
    And the "Enter HTML to customize the bottom of your search page" field should contain "New footer"
    When I go to the affiliate admin page
    When I follow "View Current"
    Then I should see "Old header"
    And I should see "Old footer"
    And I should see the page with affiliate stylesheet "default"
    And I should not see the page with affiliate stylesheet "basic_gray"
    When I go to the affiliate admin page
    When I follow "View staged"
    Then I should see "New header"
    And I should see "New footer"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with affiliate stylesheet "default"
    When I go to the affiliate admin page
    And I press "Push Changes"
    Then I should be on the affiliate admin page
    And I should see "Staged content is now visible"
    And I should not see "Push Changes"
    And I should not see "View staged"
    When I follow "View Current"
    Then I should see "New header"
    And I should see "New footer"
    And I should see the page with affiliate stylesheet "basic_gray"
    And I should not see the page with affiliate stylesheet "default"

  Scenario: Related Topics on English SERPs for given affiliate search
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And the following Calais Related Searches exist for affiliate "aff.gov":
      | term    | related_terms             | locale |
      | obama   | Some Unique Related Term  | en     |
    When I go to aff.gov's search page
    And I fill in "query" with "obama"
    And I press "Search"
    Then I should see "Related Topics"
    And I should see "Some Unique Related Term"
    And I should not see "aff.gov"

  Scenario: Affiliate SAYT
    Given the following Affiliates exist:
      | display_name      | name            | contact_email             | contact_name          | domains        | is_sayt_enabled | is_affiliate_suggestions_enabled |
      | aff site          | aff.gov           | aff@bar.gov             | John Bar              | usa.gov        | true            | false                            |
      | other site        | otheraff.gov      | otheraff@bar.gov        | Other John Bar        | usa.gov        | false           | false                            |
      | another site      | anotheraff.gov    | anotheraff@bar.gov      | Another John Bar      | usa.gov        | true            | true                             |
      | yet another site  | yetanotheraff.gov | yetanotheraff@bar.gov   | Yet Another John Bar  | usa.gov        | false           | true                             |
    When I go to aff.gov's search page
    Then the search bar should have SAYT enabled
    And affiliate SAYT suggestions for "aff.gov" should be disabled
    And I fill in "query" with "emergency"
    And I submit the search form
    Then the search bar should have SAYT enabled
    And affiliate SAYT suggestions for "aff.gov" should be disabled

    When I go to otheraff.gov's search page
    Then the search bar should not have SAYT enabled
    And affiliate SAYT suggestions for "otheraff.gov" should be disabled
    And I fill in "query" with "emergency"
    And I submit the search form
    Then the search bar should not have SAYT enabled
    And affiliate SAYT suggestions for "otheraff.gov" should be disabled

    When I go to anotheraff.gov's search page
    Then the search bar should have SAYT enabled
    And affiliate SAYT suggestions for "anotheraff.gov" should be enabled
    And I fill in "query" with "emergency"
    And I submit the search form
    Then the search bar should have SAYT enabled
    And affiliate SAYT suggestions for "anotheraff.gov" should be enabled

    When I go to yetanotheraff.gov's search page
    Then the search bar should not have SAYT enabled
    And affiliate SAYT suggestions for "yetanotheraff.gov" should be disabled
    And I fill in "query" with "emergency"
    And I submit the search form
    Then the search bar should not have SAYT enabled
    And affiliate SAYT suggestions for "yetanotheraff.gov" should be disabled

  Scenario: Doing an advanced affiliate search
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        | domains        | header                | footer                |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            | usa.gov        | Affiliate Header      | Affiliate Footer      |
    When I go to aff.gov's search page
    And I follow "Advanced Search"
    Then I should see "Header"
    And I should see "Footer"
    And I should see "Use the options on this page to create a very specific search for aff site"
    And I should not see "aff.gov"
    When I fill in "query" with "emergency"
    And I press "Search"
    Then I should see "Results 1-10"
    And I should see "emergency"

    When I am on the affiliate advanced search page for "aff.gov"
    And I fill in "query-or" with "barack obama"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "barack OR obama"

    When I am on the affiliate advanced search page for "aff.gov"
    And I fill in "query-quote" with "barack obama"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "barack obama"

    When I am on the affiliate advanced search page for "aff.gov"
    And I fill in "query-not" with "barack"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "-barack"

    When I am on the affiliate advanced search page for "aff.gov"
    And I select "Adobe PDF" from "filetype"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "filetype:pdf"

    When I am on the affiliate advanced search page for "aff.gov"
    And I fill in "query" with "barack obama"
    And I select "20" from "per-page"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should see "Results 1-20"

    When I am on the affiliate advanced search page for "aff.gov"
    And I choose "No filter"
    And I press "Search"
    Then I should see "Affiliate Header"
    And I should see "Affiliate Footer"
    And I should not see "Sorry, no results found"

  Scenario: Getting an embed code for my affiliate site search
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Get Code"
    Then I should see "USASearch > Affiliate Program > Affiliate Center > aff site > Get Code"
    And I should see "The following is the HTML code for your search box form. Copy and paste this code into your page(s) where the search box should appear."
    And I should see "Code for English-language sites"
    And I should see "Code for Spanish-language sites"
    And I should see "Do you want to have Type-ahead Search box on your home page and/or in your banner?"
    And I should see "How To Implement Type-ahead Search"
    When I follow "Type-ahead Search" within ".cross-promotion"
    Then I should see "Add a New Entry"
    And I should not see "aff.gov"

  Scenario: Navigating to an Affiliate page for a particular Affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "aff site"
    Then I should see "USASearch > Affiliate Program > Affiliate Center > aff site"
    And I should see "Affiliate: aff site"
    And I should not see "aff.gov"

  Scenario: Stats link on affiliate home page
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And there is analytics data for affiliate "aff.gov" from "20100401" thru "20100415"
    When I go to the affiliate admin page with "aff.gov" selected
    Then I should see "Analytics"

  Scenario: Getting stats for an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And there is analytics data for affiliate "aff.gov" from "20100401" thru "20100415"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Query Logs"
    Then I should see "USASearch > Affiliate Program > Affiliate Center > aff site > Query Analytics"
    And I should see "Query Logs for aff site"
    And I should not see "aff.gov"
    And I should see "Most Frequent Queries"
    And I should see "Data for April 15, 2010"
    And in "dqs1" I should not see "No queries matched"
    And in "dqs7" I should not see "No queries matched"
    And in "dqs30" I should not see "No queries matched"

  Scenario: No daily query stats available for any time period
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And there are no daily query stats
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Query Logs"
    Then in "dqs1" I should see "Not enough historic data"
    And in "dqs7" I should see "Not enough historic data"
    And in "dqs30" I should see "Not enough historic data"

  Scenario: Viewing Query Search page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email           | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And the following DailyQueryStats exist:
      | query                       | times | affiliate     | locale |   days_back   |
      | pollution                   | 100   | aff.gov       | en     |      1        |
      | old pollution               | 10    | aff.gov       | en     |      30       |
      | pollutant                   | 90    | usasearch.gov | en     |      1        |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Query Logs"
    And I fill in "query" with "pollution"
    And I fill in "analytics_search_start_date" with a date representing "29" days ago
    And I fill in "analytics_search_end_date" with a date representing "1" day ago
    And I press "Search"
    And I should see "USASearch > Affiliate Program > Affiliate Center > aff site > Query Search"
    And I should see "Matches for 'pollution'"
    And I should not see "Matches for 'old pollution'"
    And I should not see "Matches for 'pollutant'"
    And I should not see "aff.gov"

  Scenario: Getting usage stats for an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly Reports"
    Then I should see "USASearch > Affiliate Program > Affiliate Center > aff site > Monthly Reports"
    And I should see "Monthly Reports for aff site"
    And I should see "Monthly Usage Stats"
    And I should not see "aff.gov"

  Scenario: Viewing the Affiliates Monthly Reports page
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And the following DailyUsageStats exists for each day in yesterday's month
    | profile     | total_queries | affiliate |
    | Affiliates  | 1000          | aff.gov   |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly Reports"
    Then I should see the header for the report date
    And I should see the "aff site" queries total within "aff.gov_usage_stats"

  Scenario: Viewing the Affiliates Monthly Reports page for a month in the past
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    Given the following DailyUsageStats exist for each day in "2010-02"
     | profile | total_queries  | affiliate  |
     | Affiliates | 1000        | aff.gov    |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly Reports"
    And I select "February 2010" as the report date
    And I press "Get Usage Stats"
    Then I should see the report header for "2010-02"
    And I should see the "aff site" "Queries" total within "aff.gov_usage_stats" with a total of "28,000"

  Scenario: Viewing the Affiliates Monthly Reports page for a month in the future
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    Given the following DailyUsageStats exist for each day in "2019-02"
     | profile    | total_queries   | affiliate  |
     | Affiliates | 1000            | aff.gov    |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly Reports"
    And I select "December 2011" as the report date
    And I press "Get Usage Stats"
    Then I should see "Report information not available for the future."
    
  Scenario: Viewing SAYT Suggestions for an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead Search"
    Then I should be on the affiliate sayt page
    And I should see "USASearch > Affiliate Program > Affiliate Center > aff site > Type-ahead Search"
    And I should not see "aff.gov"

  Scenario: Setting SAYT Preferences for an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead Search"
    Then I should be on the affiliate sayt page
    And I should see "Preferences"
    And the "sayt_preferences_disable" button should be checked
    
    When I choose "sayt_preferences_enable_affiliate"
    And I press "Set Preferences"
    Then I should be on the affiliate sayt page
    And I should see "Preferences updated"
    And the "sayt_preferences_enable_affiliate" button should be checked    
    And the affiliate "aff.gov" should be set to use affiliate SAYT
    
    When I choose "sayt_preferences_enable_global"
    And I press "Set Preferences"
    Then I should be on the affiliate sayt page
    And the "sayt_preferences_enable_global" button should be checked
    And the affiliate "aff.gov" should be set to use global SAYT
    
    When I choose "sayt_preferences_disable"
    And I press "Set Preferences"
    Then I should be on the affiliate sayt page
    And the "sayt_preferences_disable" button should be checked
    And the affiliate "aff.gov" should be disabled
    
  Scenario: Adding and removing a SAYT Suggestion to an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead Search"
    Then I should be on the affiliate sayt page
    And I should see "Add a New Entry"
    When I fill in "Phrase" with "banana"
    And I press "Add"
    Then I should be on the affiliate sayt page
    And I should see "Successfully added: banana"
    And I should see "banana" within "#sayt-suggestions"
    
    When I fill in "Phrase" with "banana"
    And I press "Add"
    Then I should be on the affiliate sayt page
    And I should see "Unable to add: banana"
    
    When I press "Delete"
    Then I should be on the affiliate sayt page
    And I should see "Deleted phrase: banana"
    And I should not see "banana" within "#sayt-suggestions"
    
  Scenario: Uploading SAYT Suggestions for an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead Search"
    Then I should be on the affiliate sayt page
    And I should see "Bulk Upload"
    
    When I attach the file "features/support/sayt_suggestions.txt" to "txtfile"
    And I press "Upload"
    Then I should be on the affiliate sayt page
    And I should see "5 Type-ahead Search suggestions uploaded successfully"
    
    When I attach the file "features/support/sayt_suggestions.txt" to "txtfile"
    And I press "Upload"
    Then I should be on the affiliate sayt page
    And I should see "5 Type-ahead Search suggestions ignored"
    
    When I attach the file "features/support/cant_read_this.doc" to "txtfile"
    And I press "Upload"
    Then I should be on the affiliate sayt page
    And I should see "Your file could not be processed."
    
  Scenario: Viewing Related Topics for an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Related Topics"
    Then I should be on the affiliate related topics page
    And I should see "USASearch > Affiliate Program > Affiliate Center > aff site > Related Topics"
    And I should not see "aff.gov"
    
  Scenario: Setting Related Topics Preferences for an affiliate
    Given the following Affiliates exist:
     | display_name     | name             | contact_email           | contact_name        |
     | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Related Topics"
    Then I should be on the affiliate related topics page
    And I should see "Preferences"
    And the "related_topics_setting_affiliate_enabled" button should be checked
    
    When I choose "related_topics_setting_global_enabled"
    And I press "Set Preferences"
    Then I should be on the affiliate related topics page
    And the "related_topics_setting_global_enabled" button should be checked
    And the affiliate "aff.gov" should be set to use global related topics
    
    When I choose "related_topics_setting_affiliate_enabled"
    And I press "Set Preferences"
    Then I should be on the affiliate related topics page
    And I should see "Preferences updated"
    And the "related_topics_setting_affiliate_enabled" button should be checked    
    And the affiliate "aff.gov" should be set to use affiliate related topics
    
    When I choose "related_topics_setting_disabled"
    And I press "Set Preferences"
    Then I should be on the affiliate related topics page
    And the "related_topics_setting_disabled" button should be checked
    And the affiliate "aff.gov" related topics should be disabled

  Scenario: Viewing Manage Users for an affiliate
    Given the following Affiliates exist:
      | display_name     | name             | contact_email           | contact_name        |
      | aff site         | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Manage Users"
    Then I should see "USASearch > Affiliate Program > Affiliate Center > aff site > Manage Users"
    And I should see "Users for Affiliate: aff site"
    And I should see "John Bar (aff@bar.gov)"
    And I should not see "aff.gov"
