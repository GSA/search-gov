Feature: Affiliate clients
  In order to give my searchers a custom search experience
  As an affiliate
  I want to see and manage my affiliate settings

  Scenario: Visiting the affiliate welcome/list page as a un-authenticated Affiliate
    When I go to the affiliate welcome page
    Then I should see "FAQs"

  Scenario: Visiting the account page as a logged-in affiliate
    Given the following Affiliates exist:
    | name             | contact_email         | contact_name        |
    | multi1           | two@bar.gov           | Two Bar             |
    | multi2           | two@bar.gov           | Two Bar             |
    And I am logged in with email "two@bar.gov" and password "random_string"
    When I go to the user account page
    Then I should see "multi1"
    And I should see "multi2"
    And I should see "FAQ"
    When I follow "Edit"
    And I fill in "Name" with "newname"
    And I fill in "Header" with "My header"
    And I fill in "Footer" with "My footer"
    And I fill in "Domains" with "foo.com bar.com"
    And I press "Update affiliate"
    Then I should see "Updated your affiliate successfully."
    And I should be on the user account page
    And I should see "newname"
    When I follow "View sample"
    Then I should see "My header"
    And I should see "My header"
