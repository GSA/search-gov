Feature: Clicks and Queries stats
  In order to see the correlation between user queries and clicked URLs
  As a site customer
  I want to see top clicked URLs, the queries that led to them, and the clicked URLs that came from those queries

  Scenario: Viewing the Site's Analytics
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name |
      | aff site     | aff.gov | aff@bar.gov   | John Bar     |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the aff.gov's Analytics page
    And I follow "Queries"
    Then I should see "Queries"
    And I should see "Your site has not received any search queries yet"

    When I fill in "Query" with "nothing to see here"
    And I press "Generate Report"
    Then I should see "Sorry, no results found for 'nothing to see here'"

    When I follow "Clicks"
    Then I should see "Clicks"
    And I press "Generate Report"
    Then I should see "Your site has not received any clicks on search results yet."

    When I follow "Referrers"
    Then I should see "Referrers"
    And I should see "Your site has not received any queries with referrers yet."

