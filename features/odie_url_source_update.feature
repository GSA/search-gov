Feature: ODIE URL Source Update
  In order to meet customer needs
  As an admin
  I want to update the source of all of a specific affiliate's indexed documents from rss to manual

  Scenario: Bulk updating indexed document source as an admin
    Given the following Affiliates exist:
      | display_name | name   | contact_email                  |
      | USA.gov      | usagov | affiliate_admin@fixtures.org   |
    Given I am logged in with email "affiliate_admin@fixtures.org"
    When I go to the the odie url source update admin page
    Then I should see "ODIE URL Source Update"
    And I should see "Enter affiliate handle"

    When I fill in "affiliate_name" with "agency site"
    And I press "Search"
    Then I should be on the odie url source update admin page
    And I should see "No affiliate matches the handle agency site."

    When I fill in "affiliate_name" with "usagov"
    And I press "Search"
    Then I should be on the odie url source update affiliate lookup page
    And I should see "Update ODIE url source to manual for the following affiliate?"
    And the "run_update_job" input should be disabled

    Given there are 5 rss indexed documents for affiliate "usagov"
    When I follow "Search for a different affiliate"
    And I fill in "affiliate_name" with "usagov"
    And I press "Search"
    Then I should be on the odie url source update affiliate lookup page
    And I should see "Update ODIE url source to manual for the following affiliate?"
    And the "run_update_job" input should not be disabled

    When I submit the form by pressing "Update Affiliate usagov"
    Then I should be on the odie url source update update job page
    And I should see "ODIE URL Source Update job enqueued for affiliate usagov."
