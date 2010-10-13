Feature:  Administration
  Scenario: Visiting the admin home page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    Then I should see "Users"
    And I should see "Affiliates"
    And I should see "Affiliate Broadcast"
    And I should see "Calais Related Searches"
    And I should see "SAYT Filters"
    And I should see "SAYT Suggestions Bulk Upload"
    And I should see "Search.USA.gov Boosted Sites"
    And I should see "Affiliate Boosted Sites"
    And I should see "Spotlights"
    And I should see "FAQs"
    And I should not see "Query Grouping"
    And I should see "affiliate_admin@fixtures.org"
    And I should see "My Account"
    And I should see "Logout"
    When I follow "Logout"
    Then I should be on the login page

  Scenario: Visiting the admin home page as Marilyn
    Given I am logged in with email "marilyn@fixtures.org" and password "admin"
    When I go to the admin home page
    Then I should see "Users"
    And I should see "Query Grouping"

  Scenario: Sending a welcome email to all affiliates
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Affiliates exist:
    | name             | contact_email         | contact_name        |
    | single           | one@foo.gov           | One Foo             |
    | multi1           | two@bar.gov           | Two Bar             |
    | multi2           | two@bar.gov           | Two Bar             |
    And a clear email queue
    When I go to the affiliate admin broadcast page
    And I fill in "Subject" with "some title"
    And I fill in "Body" with "This is the email body"
    And I press "Send to all affiliates"
    Then I should be on the affiliate admin home page
    And I should see "Message broadcasted to all affiliates successfully"
    And "one@foo.gov" should receive 1 email
    And "two@bar.gov" should receive 1 email
    When "one@foo.gov" opens the email with subject "some title"
    Then they should see "This is the email body" in the email body
    And they should see "One Foo" in the email body
    And they should see "single" in the email body
    When "two@bar.gov" opens the email with subject "some title"
    Then they should see "This is the email body" in the email body
    And they should see "Two Bar" in the email body
    And they should see "multi1" in the email body
    And they should see "multi2" in the email body


  Scenario: Uploading, as a logged in admin, a SAYT suggestions text file containing:
            3 new SAYT suggestions, 1 that already exists exactly, 1 that exists in a different case, and a blank line
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following SAYT Suggestions exist:
      | phrase             |
      | tsunami            |
      | hurricane          |
    When I go to the admin home page
    And I follow "SAYT Suggestions Bulk Upload"
    Then I should see "Use a plain text file with one search suggestion per line."

    When I attach the file "features/support/sayt_suggestions.txt" to "txtfile"
    And I press "Upload"
    Then I should see "3 SAYT suggestions uploaded successfully. 2 SAYT suggestions ignored."

  Scenario: Uploading an invalid SAYT suggestions text file as a logged in admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    And I follow "SAYT Suggestions Bulk Upload"
    And I attach the file "features/support/cant_read_this.doc" to "txtfile"
    And I press "Upload"
    Then I should see "Your file could not be processed."
    
  Scenario: Viewing Boosted Sites (both affiliate and Search.USA.gov)
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And the following Boosted Sites exist:
    | title               | url                     | description                               |
    | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      |
    | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         |
    | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |
    And the following Affiliates exist:
    | name             | contact_email         | contact_name        |
    | bar.gov          | aff@bar.gov           | John Bar            |
    And the following Boosted Sites exist for the affiliate "bar.gov"
    | title               | url                     | description                               |
    | Bar Emergency Page  | http://www.bar.gov/911  | This should not show up in results        |
    When I go to the admin home page
    And I follow "Search.USA.gov Boosted Sites"
    Then I should see "Our Emergency Page"
    And I should not see "Bar Emergency Page"
    
    When I go to the admin home page
    And I follow "Affiliate Boosted Sites"
    Then I should see "Bar Emergency Page"
    And I should not see "Our Emergency Page"