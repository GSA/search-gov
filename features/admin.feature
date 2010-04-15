Feature:  Administration
  Scenario: Visiting the admin home page as an admin
    Given I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    When I go to the admin home page
    Then I should see "Users"
    Then I should see "Affiliates"
    Then I should see "Affiliate Broadcast"
    Then I should see "Related Search Blocked Words"
    Then I should see "SAYT Filters"
    Then I should see "SAYT Suggestions Bulk Upload"
    Then I should see "Boosted Sites"
    Then I should see "Spotlights"
    Then I should see "FAQs"
    Then I should see "Query Grouping"
    And I should see "affiliate_admin@fixtures.org"
    And I should see "My Account"
    And I should see "Logout"
    When I follow "Logout"
    Then I should be on the login page

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

  Scenario: Seeing click thru details from user searches
    Given I am on the homepage
    And I fill in "query" with "barack obama biography"
    And I submit the search form
    And I follow "Inauguration Day 2009"
    When I am logged in with email "affiliate_admin@fixtures.org" and password "admin"
    And I go to the admin home page
    And I follow "Search Clickthrus"
    Then I should see "barack obama biography"


