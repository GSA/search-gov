Feature: Affiliate clients
  In order to give my searchers a custom search experience
  As an affiliate
  I want to see and manage my affiliate settings

  Scenario: Visiting the affiliate welcome/list page as a un-authenticated Affiliate
    When I go to the affiliate welcome page
    Then I should see "Hosted Search Services"
    Then I should see "Affiliate Program"
    And I should see "API & Web Services"
    And I should see "Search.USA.gov"
    And I should not see "USA Search Program"
    And I should not see "Admin Center"
    And I should not see "Analytics Center"
    And I should not see "Affiliate Center"
    And I should not see "Developer"

  Scenario: Visiting the affiliate welcome page as affiliate admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the affiliate welcome page
    Then I should see "Admin Center"
    And I should not see "Analytics Center"
    And I should not see "Affiliate Center"

  Scenario: Visiting the affiliate welcome page as analyst admin
    Given I am logged in with email "analyst_admin@fixtures.org" and password "admin"
    When I go to the affiliate welcome page
    Then I should see "Analytics Center"
    And I should not see "Admin Center"

  Scenario: Visiting the affiliate welcome page as affiliate
    Given I am logged in with email "affiliate_manager@fixtures.org" and password "admin"
    When I go to the affiliate welcome page
    Then I should see "Affiliate Center"
    And I should not see "Admin Center"
    And I should not see "Analytics Center"

  Scenario: Visiting the account page as a logged-in user with affiliates
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        |
      | multi1           | two@bar.gov           | Two Bar             |
      | multi2           | two@bar.gov           | Two Bar             |
    And I am logged in with email "two@bar.gov" and password "random_string"
    When I go to the user account page
    Then I should see "multi1"
    And I should see "multi2"

  Scenario: Adding a new affiliate
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the affiliate admin page
    And I follow "Add New Affiliate"
    And I fill in the following:
      | Name of new site search                                               | www.agency.gov             |
      | Your Website URL (www.example.gov)                                    | www.agency.gov             |
      | Domains (one per line)                                                | agency.gov                 |
      | Enter HTML to customize the top of your search page                   | My header                  |
      | Enter HTML to customize the bottom of your search page                | My footer                  |
    And I press "Create"
    Then I should be on the affiliate admin page
    And I should see "Affiliate successfully created"
    And I should see "agency.gov"

  Scenario: Adding an affiliate with problems
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        |
      | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "new"
    And I fill in "name" with "aff.gov"
    And I press "Create"
    Then I should see "Name has already been taken"

  Scenario: Deleting an affiliate
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        |
      | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I press "Delete Affiliate"
    Then I should be on the affiliate admin page
    And I should see "Affiliate deleted"

  Scenario: Staging changes to an affiliate's look and feel
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        | domains        | header      | footer      | staged_domains  | staged_header    | staged_footer  |
      | aff.gov          | aff@bar.gov           | John Bar            | oldagency.gov  | Old header  | Old footer  | oldagency.gov    | Old header      | Old footer    |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page
    And I follow "Edit"
    Then the "Domains (one per line)" field should contain "oldagency.gov"
    And the "Enter HTML to customize the top of your search page" field should contain "Old header"
    And the "Enter HTML to customize the bottom of your search page" field should contain "Old footer"
    When I fill in the following:
      | Name of new site search                                               | newname                    |
      | Your Website URL (www.example.gov)                                    | www.agency.gov             |
      | Domains (one per line)                                                | newagency.gov              |
      | Enter HTML to customize the top of your search page                   | New header                 |
      | Enter HTML to customize the bottom of your search page                | New footer                 |
    And I press "Save for preview"
    Then I should see "Staged changes to your affiliate successfully."
    And I should be on the affiliate admin page
    And I should see "newname"
    When I follow "Edit"
    Then the "Domains (one per line)" field should contain "newagency.gov"
    And the "Enter HTML to customize the top of your search page" field should contain "New header"
    And the "Enter HTML to customize the bottom of your search page" field should contain "New footer"
    When I go to the affiliate admin page
    When I follow "View Current"
    Then I should see "Old header"
    And I should see "Old footer"
    When I go to the affiliate admin page
    When I follow "View staged"
    Then I should see "New header"
    And I should see "New footer"
    When I go to the affiliate admin page
    And I press "Push Changes"
    Then I should be on the affiliate admin page
    And I should see "Staged content is now visible"
    And I should not see "Push Changes"
    And I should not see "View staged"
    When I follow "View Current"
    Then I should see "New header"
    And I should see "New footer"

  Scenario: Related Topics on English SERPs for given affiliate search
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        |
      | aff.gov          | aff@bar.gov           | John Bar            |
    And the following Calais Related Searches exist for affiliate "aff.gov":
      | term    | related_terms             | locale |
      | obama   | Some Unique Related Term  | en     |
    When I go to aff.gov's search page
    And I fill in "query" with "obama"
    And I press "Search"
    Then I should see "Related Topics"
    And I should see "Some Unique Related Term"

  Scenario: Site visitor sees relevant boosted results for given affiliate search
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        |
      | aff.gov          | aff@bar.gov           | John Bar            |
      | bar.gov          | aff@bar.gov           | John Bar            |
    And the following Boosted Sites exist for the affiliate "aff.gov"
      | title               | url                     | description                               |
      | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      |
      | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         |
      | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |
    And the following Boosted Sites exist for the affiliate "bar.gov"
      | title               | url                     | description                               |
      | Bar Emergency Page  | http://www.bar.gov/911  | This should not show up in results        |
      | Pelosi misspelling  | http://www.bar.gov/pel  | Synonyms file test works                  |
      | all about agencies  | http://www.bar.gov/pel  | Stemming works                            |
    When I go to aff.gov's search page
    And I fill in "query" with "emergency"
    And I submit the search form
    Then I should see "Our Emergency Page" within "#boosted"
    And I should see "FAQ Emergency Page" within "#boosted"
    And I should not see "Our Tourism Page" within "#boosted"
    And I should not see "Bar Emergency Page" within "#boosted"

    When I go to bar.gov's search page
    And I fill in "query" with "Peloci"
    And I submit the search form
    Then I should see "Synonyms file test works" within "#boosted"

    When I go to bar.gov's search page
    And I fill in "query" with "agency"
    And I submit the search form
    Then I should see "Stemming works" within "#boosted"

  Scenario: Uploading valid booster XML document as a logged in affiliate
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        |
      | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted sites"
    Then I should see "aff.gov has no boosted sites"
    And I should see "Upload boosted sites for aff.gov"

    When I attach the file "features/support/boosted_sites.xml" to "xmlfile"
    And I press "Upload"
    Then I should see "Boosted sites uploaded successfully for affiliate 'aff.gov'"

    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted sites"
    Then I should see "This is a listing about Texas"
    And I should see "Some other listing about hurricanes"
    And I should see "Upload boosted sites for aff.gov"

    When I attach the file "features/support/new_boosted_sites.xml" to "xmlfile"
    And I press "Upload"
    And I follow "Boosted sites"
    Then I should see "New results about Texas"
    And I should see "New results about hurricanes"

  Scenario: Uploading invalid booster XML document as a logged in affiliate
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        |
      | aff.gov          | aff@bar.gov           | John Bar            |
    And the following Boosted Sites exist for the affiliate "aff.gov"
      | title               | url                     | description                               |
      | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      |
      | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         |
      | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Boosted sites"
    And I attach the file "features/support/missing_title_boosted_sites.xml" to "xmlfile"
    And I press "Upload"
    Then I should see "Your XML document could not be processed. Please check the format and try again."
    And I should see "Our Emergency Page"
    And I should see "FAQ Emergency Page"
    And I should see "Our Tourism Page"

    When I go to aff.gov's search page
    And I fill in "query" with "tourism"
    And I submit the search form
    Then I should see "Our Tourism Page" within "#boosted"

  Scenario: Affiliate SAYT
    Given the following Affiliates exist:
      | name            | contact_email             | contact_name          | domains        | is_sayt_enabled | is_affiliate_suggestions_enabled |
      | aff.gov           | aff@bar.gov             | John Bar              | usa.gov        | true            | false                            |
      | otheraff.gov      | otheraff@bar.gov        | Other John Bar        | usa.gov        | false           | false                            |
      | anotheraff.gov    | anotheraff@bar.gov      | Another John Bar      | usa.gov        | true            | true                             |
      | yetanotheraff.gov | yetanotheraff@bar.gov   | Yet Another John Bar  | usa.gov        | false           | true                             |
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
      | name             | contact_email         | contact_name        | domains        | header                | footer                |
      | aff.gov          | aff@bar.gov           | John Bar            | usa.gov        | Affiliate Header      | Affiliate Footer      |
    When I go to aff.gov's search page
    And I follow "Advanced Search"
    Then I should see "Header"
    And I should see "Footer"
    And I should see "Use the options on this page to create a very specific search for aff.gov"
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
      | name             | contact_email         | contact_name        |
      | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Get Code"
    Then I should see "Embed Search Code"
    And I should see "Copy and paste the HTML code below to create a search box for aff.gov"
    And I should see "English Version"
    And I should see "Spanish Version"
  
  Scenario: Navigating to an Affiliate page for a particular Affiliate
    Given the following Affiliates exist:
      | name             | contact_email         | contact_name        |
      | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "aff.gov"
    Then I should see "Affiliate: aff.gov"

  Scenario: Stats link on affiliate home page
    Given the following Affiliates exist:
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And there is analytics data for affiliate "aff.gov" from "20100401" thru "20100415"
    When I go to the affiliate admin page with "aff.gov" selected
    Then I should see "Analytics"

  Scenario: Getting stats for an affiliate
    Given the following Affiliates exist:
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And there is analytics data for affiliate "aff.gov" from "20100401" thru "20100415"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Query Logs"
    Then I should see "Query Analytics for aff.gov"
    And I should see "Most Frequent Queries"
    And I should see "Data for April 15, 2010"
    And in "dqs1" I should not see "No queries matched"
    And in "dqs7" I should not see "No queries matched"
    And in "dqs30" I should not see "No queries matched"

  Scenario: No daily query stats available for any time period
    Given the following Affiliates exist:
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    And there are no daily query stats
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Query Logs"
    Then in "dqs1" I should see "Not enough historic data"
    And in "dqs7" I should see "Not enough historic data"
    And in "dqs30" I should see "Not enough historic data"

  Scenario: Getting usage stats for an affiliate
    Given the following Affiliates exist:
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly Reports"
    Then I should see "Monthly Usage Stats"

  Scenario: Viewing the Affiliates Monthly Reports page
    Given the following Affiliates exist:
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
    And the following DailyUsageStats exists for each day in yesterday's month
    | profile     | total_queries | affiliate |
    | Affiliates  | 1000          | aff.gov   |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly Reports"
    Then I should see the header for the report date
    And I should see the "aff.gov" queries total within "aff.gov_usage_stats"

  Scenario: Viewing the Affiliates Monthly Reports page for a month in the past
    Given the following Affiliates exist:
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
    Given the following DailyUsageStats exist for each day in "2010-02"
     | profile | total_queries  | affiliate  |
     | Affiliates | 1000        | aff.gov    |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Monthly Reports"
    And I select "February 2010" as the report date
    And I press "Get Usage Stats"
    Then I should see the report header for "2010-02"
    And I should see the "aff.gov" "Queries" total within "aff.gov_usage_stats" with a total of "28,000"

  Scenario: Viewing the Affiliates Monthly Reports page for a month in the future
    Given the following Affiliates exist:
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
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
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead Search"
    Then I should be on the affiliate sayt page
    And I should see "Dashboard > aff.gov > Type-ahead Search"
    
  Scenario: Setting SAYT Preferences for an affiliate
    Given the following Affiliates exist:
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
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
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead Search"
    Then I should be on the affiliate sayt page
    And I should see "Add Type-ahead Search Suggestion"
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
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Type-ahead Search"
    Then I should be on the affiliate sayt page
    And I should see "Type-ahead Search Suggestions Bulk Upload"
    
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
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the affiliate admin page with "aff.gov" selected
    And I follow "Related Topics"
    Then I should be on the affiliate related topics page
    And I should see "Dashboard > aff.gov > Related Topics"
    
  Scenario: Setting Related Topics Preferences for an affiliate
    Given the following Affiliates exist:
     | name             | contact_email           | contact_name        |
     | aff.gov          | aff@bar.gov             | John Bar            |
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