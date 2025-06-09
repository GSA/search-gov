Feature: Referrer stats
  In order to see the correlation between referring URLs and user queries
  As a site customer
  I want to see top referrer URLs, the queries that came from them, and the referring URLs that led to those query terms

  Scenario: Viewing the Site's Referrer Stats page
    Given the following BingV7 Affiliates exist:
      | display_name | name    | contact_email | first_name   | last_name | use_redesigned_results_page |
      | aff site     | aff.gov | aff@bar.gov   | John         | Bar       | false                       |
    And I am logged in with email "aff@bar.gov"
    When I go to the aff.gov's Analytics page
    And I follow "Referrers"
    Then I should see "Referrers"
