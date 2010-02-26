Feature: Affiliate clients
  In order to give my searchers a custom search experience
  As an affiliate
  I want to see and manage my affiliate settings

  Scenario: Visiting the affiliate welcome/list page as a un-authenticated Affiliate
    When I go to the affiliate welcome page
    Then I should see "Who are we?"
    When I follow "Register now"
    Then I should see "Sign up"

  Scenario: Visiting the account page as a logged-in user with affiliates
    Given the following Affiliates exist:
    | name             | contact_email         | contact_name        |
    | multi1           | two@bar.gov           | Two Bar             |
    | multi2           | two@bar.gov           | Two Bar             |
    And I am logged in with email "two@bar.gov" and password "random_string"
    When I go to the user account page
    Then I should see "multi1"
    And I should see "multi2"
    And I should see "FAQ"

  Scenario: Adding a new affiliate
    Given I am logged in with email "affiliate_manager_with_no_affiliates@fixtures.org" and password "admin"
    When I go to the user account page
    And I follow "Add Affiliate"
    And I fill in the following:
    | Name of new site search                                               | www.agency.gov             |
    | Your Website URL (www.example.gov)                                    | www.agency.gov             |
    | Domains (one per line)                                                | agency.gov                 |
    | Enter HTML to customize the top of your search page                   | My header                  |
    | Enter HTML to customize the bottom of your search page                | My footer                  |
    And I press "Create"
    Then I should be on the user account page
    And I should see "Affiliate successfully created"
    And I should see "agency.gov"

  Scenario: Adding an affiliate with problems
    Given the following Affiliates exist:
    | name             | contact_email         | contact_name        |
    | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the user account page
    And I follow "new"
    And I fill in "name" with "aff.gov"
    And I press "Create"
    Then I should see "Name has already been taken"

  Scenario: Deleting an affiliate
    Given the following Affiliates exist:
    | name             | contact_email         | contact_name        |
    | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the user account page
    And I press "Delete Affiliate"
    Then I should be on the user account page
    And I should see "Affiliate deleted"

  Scenario: Staging changes to an affiliate's look and feel
    Given the following Affiliates exist:
    | name             | contact_email         | contact_name        | domains			| header		| footer		| staged_domains	| staged_header	| staged_footer	|
    | aff.gov          | aff@bar.gov           | John Bar            | oldagency.gov	| Old header	| Old footer	| oldagency.gov		| Old header			| Old footer	|						
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the user account page
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
    And I should be on the user account page
    And I should see "newname"
    When I follow "Edit"
    Then the "Domains (one per line)" field should contain "newagency.gov"
    And the "Enter HTML to customize the top of your search page" field should contain "New header"
    And the "Enter HTML to customize the bottom of your search page" field should contain "New footer"
    When I go to the user account page
    When I follow "View current"
    Then I should see "Old header"
    And I should see "Old footer"
    When I go to the user account page
    When I follow "View staged"
    Then I should see "New header"
    And I should see "New footer"
    When I go to the user account page
    And I press "Push Changes"
    Then I should be on the user account page
    And I should see "Staged content is now visible"
    And I should not see "Push Changes"
    And I should not see "View staged"
    When I follow "View current"
    Then I should see "New header"
    And I should see "New footer"

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
    When I go to the user account page
    And I follow "Boosted sites"
    Then I should see "aff.gov has no boosted sites"
    And I should see "Upload boosted sites for aff.gov"

    When I attach the file "features/support/boosted_sites.xml" to "xmlfile"
    And I press "Upload"
    Then I should see "Boosted sites uploaded successfully for aff.gov"

    When I follow "Boosted sites"
    Then I should see "This is a listing about Texas"
    And I should see "Some other listing about hurricanes"
    And I should see "Upload boosted sites for aff.gov"

    When I attach the file "features/support/new_boosted_sites.xml" to "xmlfile"
    And I press "Upload"
    And I follow "Boosted sites"
    Then I should see "New results about Texas"
    And I should see "New results about hurricanes"

  Scenario: Uploading invalid booster XML document (plaintext) as a logged in affiliate
    Given the following Affiliates exist:
    | name             | contact_email         | contact_name        |
    | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the user account page
    And I follow "Boosted sites"
    And I attach the file "features/support/boosted_sites.xml" to "xmlfile"
    And I press "Upload"
    And I follow "Boosted sites"
    And I attach the file "features/support/invalid_boosted_sites.txt" to "xmlfile"
    And I press "Upload"
    Then I should see "This is a listing about Texas"
    And I should see "Some other listing about hurricanes"
    And I should see "Your XML document could not be processed. Please check the format and try again."

  Scenario: Uploading invalid booster XML document (malformed) as a logged in affiliate
    Given the following Affiliates exist:
    | name             | contact_email         | contact_name        |
    | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the user account page
    And I follow "Boosted sites"
    And I attach the file "features/support/boosted_sites.xml" to "xmlfile"
    And I press "Upload"
    And I follow "Boosted sites"
    And I attach the file "features/support/invalid_boosted_sites.xml" to "xmlfile"
    And I press "Upload"
    Then I should see "This is a listing about Texas"
    And I should see "Some other listing about hurricanes"
    And I should see "Your XML document could not be processed. Please check the format and try again."
