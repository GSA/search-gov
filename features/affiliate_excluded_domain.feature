Feature: Affiliate excluded domain
  As an affiliate manager
  I want to manage my site domain exclusions
  So that I can limit search results to subsets of my site domains whitelist

  Scenario: Visiting excluded site domains index page
    Given the following Affiliates exist:
      | display_name | name       | contact_email                | contact_name |
      | agency site  | agency.gov | affiliate_manager@agency.gov | John Bar     |
    And I am logged in with email "affiliate_manager@agency.gov" and password "random_string"
    When I go to the affiliate admin page with "agency.gov" selected
    And I follow "Excluded Domains"
    Then I should see the browser page titled "Excluded Domains"
    And I should see the following breadcrumbs: USASearch > Admin Center > agency site > Excluded Domains
    And I should see "Excluded Domains" in the page header
    And I should see "Site agency site has no excluded domains"

    When the following excluded site domains exist for the affiliate agency.gov:
      | domain               |
      | beta.whitehouse.gov  |
      | beta.usa.gov         |
      | beta.gobiernousa.gov |
    And I go to the affiliate admin page with "agency.gov" selected
    And I follow "Excluded Domains"
    Then I should see the following table rows:
      | Domain               |
      | beta.gobiernousa.gov |
      | beta.usa.gov         |
      | beta.whitehouse.gov  |

  Scenario: Adding and deleting excluded site domain
    Given the following Affiliates exist:
      | display_name | name       | contact_email                | contact_name |
      | agency site  | agency.gov | affiliate_manager@agency.gov | John Bar     |
    And the following excluded site domains exist for the affiliate agency.gov:
      | domain       |
      | beta.usa.gov |
    And I am logged in with email "affiliate_manager@agency.gov" and password "random_string"
    When I go to the affiliate admin page with "agency.gov" selected
    And I follow "Excluded Domains"
    And I press "Delete"
    Then I should see "Excluded domain successfully deleted."
    And I should see the following breadcrumbs: USASearch > Admin Center > agency site > Excluded Domains
    And I should see "Site agency site has no excluded domains"

    When I fill in "Domain" with "beta.nps.gov"
    And I press "Add"
    Then I should see "Excluded domain successfully created."
    And I should see the following breadcrumbs: USASearch > Admin Center > agency site > Excluded Domains
    And I should see the following table rows:
      | Domain       |
      | beta.nps.gov |

    When I fill in "Domain" with "beta.nps.gov"
    And I press "Add"
    Then I should see "Domain has already been taken"